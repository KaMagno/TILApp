import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    //Register a new route at /api/acronyms that accepts a POST request and returns Future<Acronym>. It returns the acronym once it’s saved
    router.post("api","acronyms") { (request) -> Future<Acronym> in
        
        //Decode the request’s JSON into an Acronym model using Codable. This returns a Future<Acronym> so it uses a flatMap(to:) to extract the acronym when the decoding is complete. Note this is different from how data is decoded in Chapter 2, “Hello Vapor!”. In this route handler, you are calling decode(_:) on Request yourself. You are then unwrapping the result as decode(_:) returns a Future<Acronym>.
        return try request.content.decode(Acronym.self).flatMap({ (acronym) -> EventLoopFuture<Acronym> in
            
            //Save the model using Fluent. This returns Future<Acronym> as it returns the model once it’s saved.
            return acronym.save(on: request)
        })
    }
    
    //Get all Acronyms
    router.get("api","acronyms") { (request) -> Future<[Acronym]> in
        
        //Perform a query to get all the acronyms.
        return Acronym.query(on: request).all()
    }
    
    //Get an Acronyms
    router.get("api","acronyms",Acronym.parameter) { (request) -> Future<Acronym> in
        
        //Extract the acronym from the request using the parameter function. This function performs all the work necessary to get the acronym from the database. It also handles the error cases when the acronym does not exist, or the ID type is wrong, for example, when you pass it an integer when the ID is a UUID.
        return try request.parameters.next(Acronym.self)
    }
    
    //Update an Acronym
    router.put("api","acronyms",Acronym.parameter) { (request) -> Future<Acronym> in
        //Use flatMap(to:_:_:), the dual future form of flatMap, to wait for both the parameter extraction and content decoding to complete. This provides both the acronym from the database and acronym from the request body to the closure
        return try flatMap(to: Acronym.self, request.parameters.next(Acronym.self), request.content.decode(Acronym.self),
                           { acronym, updatedAcronym in
                            //Update the acronym’s properties with the new values.
                            acronym.short = updatedAcronym.short
                            acronym.long = updatedAcronym.long
                            
                            //Save the acronym and return the result
                            return acronym.save(on: request)
        })
    }
    
    //Delete
    router.delete("api","acronyms",Acronym.parameter) { (request) -> Future<HTTPStatus> in
        //Extract the acronym to delete from the request’s parameters.
        let acronymParameter = try request.parameters.next(Acronym.self)
        //Delete the acronym using delete(on:). Instead of requiring you to unwrap the returned Future, Fluent allows you to call delete(on:) directly on that Future. This helps tidy up code and reduce nesting. Fluent provides convenience functions for delete, update, create and save.
        let eventLoopFutureAcronym = acronymParameter.delete(on: request)
        //Transform the result into a 204 No Content response. This tells the client the request has successfully completed but there’s no content to return.
        let eventLoopFutureHTTPStatus = eventLoopFutureAcronym.transform(to: HTTPStatus.noContent)
        
        return eventLoopFutureHTTPStatus
    }
}
