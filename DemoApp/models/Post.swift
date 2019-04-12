//
//  Post.swift
//  v-labs
//
//  Created by Charles Etieve on 04/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import ObjectMapper

struct Post : Mappable {
    
    var userId: Int?
    var id: Int?
    var title: String?
    var body: String?
    
    mutating func mapping(map: Map) {
        userId  <- map["userId"]
        id      <- map["id"]
        title   <- map["title"]
        body    <- map["body"]
    }
    
    init?(map: Map) {
    }
}
