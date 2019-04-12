//
//  Photo.swift
//  v-labs
//
//  Created by Charles Etieve on 04/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import ObjectMapper

struct Photo : Mappable {
    
    var albumId: Int?
    var id: Int?
    var title: String?
    var url: String?
    var thumbnailUrl: String?
    
    mutating func mapping(map: Map) {
        albumId         <- map["albumId"]
        id              <- map["id"]
        title           <- map["title"]
        url             <- map["url"]
        thumbnailUrl    <- map["thumbnailUrl"]
    }
    
    init?(map: Map) {
    }
}
