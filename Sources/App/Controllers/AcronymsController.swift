import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    // MARK: - Boot
    func boot(router: Router) throws {
        let acronymsRouter = router.grouped("api","acronyms")
        
        //Register router HTTP verb's to Handlers
        acronymsRouter.post(Acronym.self, use: createHandler)
        acronymsRouter.get(use: getAllHandler)
        acronymsRouter.get(Acronym.parameter, use: getAllHandler)
        acronymsRouter.put(Acronym.parameter, use: updatedHandler)
        acronymsRouter.delete(Acronym.parameter, use: deleteHandler)
        acronymsRouter.get("search", use: searchHandler)
        acronymsRouter.get("first", use: getFirstHandler)
        acronymsRouter.get("sorted", use: sortedHandler)
        
        acronymsRouter.get(Acronym.parameter,"user", use: getUserHandler)
    }
    
    // MARK: - Handlers
    func getAllHandler(_ request:Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: request).all()
    }
    
    func createHandler(_ request:Request, acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: request)
    }
    
    func getHandler(_ request:Request) throws -> Future<Acronym> {
        return try request.parameters.next(Acronym.self)
    }
    
    func updatedHandler(_ request:Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, request.parameters.next(Acronym.self), request.content.decode(Acronym.self), { (acronym, updatedAcronym) -> EventLoopFuture<Acronym> in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            acronym.userID = updatedAcronym.userID
            return acronym.save(on: request)
        })
    }
    
    
    func deleteHandler(_ request:Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(Acronym.self).delete(on: request).transform(to: HTTPStatus.noContent)
    }
    
    
    func searchHandler(_ request:Request) throws -> Future<[Acronym]> {
        guard let searchTerm = request.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return Acronym.query(on: request).group(.or, closure: { (or) in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }).all()
    }
    
    func getFirstHandler(_ request:Request) throws -> Future<Acronym> {
        return Acronym.query(on: request).first().map(to: Acronym.self, { (acronym) -> Acronym in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            
            return acronym
        })
    }
    
    func sortedHandler(_ request:Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: request).sort(\.short, .ascending).all()
    }
    
    // MARK: Relations Handler's
    func getUserHandler(_ request: Request) throws -> Future<User> {
        return try request.parameters.next(Acronym.self).flatMap(to: User.self, { (acronym) -> EventLoopFuture<User> in
            return acronym.user.get(on: request)
        })
    }
}
