//
//  DataModel.swift
//  DiaryApp
//
//  Created by rlogical-dev-11 on 18/11/20.
//

import Foundation
import ObjectMapper

class DairyModel: Mappable,Codable {
    
    var content : String!
    var date : String!
    var id : String!
    var title : String!
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        content <- map["content"]
        date <- map["date"]
        id <- map["id"]
        title <- map["title"]
    }
    
    
    func toJSON() -> [String : Any] {
        var dictionary = [String:Any]()
        
        if content != nil{
            dictionary["content"] = content
        }
        if date != nil{
            dictionary["date"] = date
        }
        if id != nil{
            dictionary["id"] = id
        }
        if title != nil{
            dictionary["title"] = title
        }
        
        return dictionary
    }
}
