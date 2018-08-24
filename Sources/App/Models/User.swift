import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

extension User {
    //Add a computed property to User to get an user's acornyms. This returns Fluents generic Children type.
    var acronyms: Children<User,Acronym> {
        //User Fluent's children(_:) function to retrieve the children. This takes the key path of the user eference on the acronym.
        return children(\.userID)
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User: Migration {}
extension User: Parameter {}
