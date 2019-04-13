//
//  Comment.swift
//  DemoApp
//
//  Created by Charles Etieve on 05/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import ObjectMapper

struct Comment : Mappable {
    
    var postId: Int?
    var id: Int?
    var name: String?
    var email: String?
    var body: String?
    
    mutating func mapping(map: Map) {
        postId  <- map["postId"]
        id      <- map["id"]
        name    <- map["name"]
        email   <- map["email"]
        body    <- map["body"]
    }
    
    init?(map: Map) {
    }
}
