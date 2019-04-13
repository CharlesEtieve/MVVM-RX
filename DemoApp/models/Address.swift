//
//  Address.swift
//  DemoApp
//
//  Created by Charles Etieve on 01/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import ObjectMapper

struct Address : Mappable {
    var street: String?
    var suite: String?
    var city: String?
    var zipcode: String?
    var latitude: Double?
    var longitude: Double?
    
    mutating func mapping(map: Map) {
        street      <- map["street"]
        suite       <- map["suite"]
        city        <- map["city"]
        zipcode     <- map["zipcode"]
        latitude    <- map["geo.lat"]
        longitude   <- map["geo.long"]
    }
    
    init?(map: Map) {
    }
}
