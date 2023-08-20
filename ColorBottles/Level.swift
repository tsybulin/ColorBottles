//
//  Level.swift
//  ColorBottles
//
//  Created by Pavel Tsybulin on 12.08.2023.
//

import Foundation

class Bottle : Decodable {
    let id : Int
    var blocks : [String]
    
    init(id: Int, blocks: [String]) {
        self.id = id
        self.blocks = blocks
    }
}

class Level : Decodable {
    let id : Int
    let emptyBottles : Int
    let bottles : [Bottle]
}
