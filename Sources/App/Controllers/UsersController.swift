import Vapor

struct UsersController: RouteCollection {
    func boot(router:Router) throws {
        let usersRoute = router.grouped("api","users")
        
        
        //Register router HTTP Verbs to Handlers
        usersRoute.post(User.self, use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.delete(User.parameter, use: getHandler)
        usersRoute.get(User.parameter,"acronyms", use: getAcronymsHandler)
    }
    
    // MARK: - Handlers
    func createHandler(_ request: Request, user:User) throws -> Future<User> {
        return user.save(on: request)
    }
    
    func getAllHandler(_ request: Request) throws -> Future<[User]> {
        return User.query(on: request).all()
    }
    
    func getHandler(_ request: Request) throws -> Future<User> {
        return try request.parameters.next(User.self)
    }
    
    // MARK: Relations Handler's
    func getAcronymsHandler(_ request: Request) throws -> Future<[Acronym]> {
        return try request.parameters.next(User.self).flatMap(to: [Acronym].self) { user in
            try user.acronyms.query(on: request).all()
        }
    }
    
}
