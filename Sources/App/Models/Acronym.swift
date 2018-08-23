import Vapor
import FluentPostgreSQL

final class Acronym:Codable {
    var id:Int?
    var short:String?
    var long:String?
    var userID: User.ID
    
    init(short:String, long:String, userID:User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

extension Acronym {
    //Add a computed property to Acronym to get the User object of the acronym’s owner. This returns Fluent’s generic Parent type
    var user: Parent<Acronym,User> {
        //Use Fluent’s parent(_:) function to retrieve the parent. This takes the key path of the user reference on the acronym
        return parent(\.userID)
    }
}

//Make Acronym conform to Fluent’s Model.
extension Acronym: PostgreSQLModel {}

//Make the model conform to Migration
extension Acronym: Migration {}

//Content is a wrapper around Codable, which allows you to convert models and other data between various formats
extension Acronym: Content {}

//Make Acronym conform to Parameter protocol. So it can be used as a Prameter
extension Acronym: Parameter {}
