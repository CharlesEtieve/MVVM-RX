//
//  User.swift
//  v-labs
//
//  Created by Charles Etieve on 01/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import ObjectMapper

struct User : Mappable {
    
    var id: Int?
    var name: String?
    var username: String?
    var address: Address?
    var email: String?
    var phone: String?
    var website: String?
    //TODO company
    
    mutating func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        username    <- map["username"]
        email       <- map["email"]
        phone       <- map["phone"]
        website     <- map["website"]
        address     <- map["address"]
        
    }
    
    init?(map: Map) {
    }
    
}
