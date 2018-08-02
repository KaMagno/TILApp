import Vapor
import FluentSQLite

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
extension Acronym:Model {
    //Tell Fluent what database to use for this model. The template is already configured to use SQLite.
    typealias Database = SQLiteDatabase
    
    //Tell Fluent what type the ID is
    typealias ID = Int
    
    //Tell Fluent the key path of the model’s ID property.
    public static var idKey:IDKey = \Acronym.id
}

//Make the model conform to Migration
extension Acronym:Migration {}

