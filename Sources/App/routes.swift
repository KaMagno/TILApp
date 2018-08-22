import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    //Crate an Acronym Controller
    let acronymsController = AcronymsController()
    
    //Register the new type with the router to ensure the contoller's route get registered
    try router.register(collection: acronymsController)
}
