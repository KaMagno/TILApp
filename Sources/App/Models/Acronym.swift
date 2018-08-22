import Vapor
import FluentPostgreSQL

final class Acronym:Codable {
    var id:Int?
    var short:String?
    var long:String?
    
    init(short:String,long:String) {
        self.short = short
        self.long = long
    }
}

//Make Acronym conform to Fluent’s Model.
extension Acronym:PostgreSQLModel {}

//Make the model conform to Migration
extension Acronym:Migration {}

//Content is a wrapper around Codable, which allows you to convert models and other data between various formats
extension Acronym: Content {}
