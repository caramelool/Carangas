//
//  Brand.swift
//  Carangas
//
//  Created by Usuário Convidado on 14/04/18.
//  Copyright © 2018 Eric Brito. All rights reserved.
//

import Foundation

class Brand: Codable {
    var key: String = ""
    var id: Int = 0
    var fipeName: String = ""
    var name: String = ""
    
    enum CodingKeys: String, CodingKey {
        case key
        case id
        case fipeName = "fipe_name"
        case name
    }
}
