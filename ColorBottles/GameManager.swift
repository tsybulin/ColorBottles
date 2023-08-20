//
//  GameManager.swift
//  ColorBottles
//
//  Created by Pavel Tsybulin on 12.08.2023.
//

import Foundation

class GameManager : NSObject {
    static let shared = GameManager()
    
    var levels : [Level] = []
    
    override private init() {
        super.init()
    }
    
    func loadLevels() {
        guard let lvlUrl = Bundle.main.url(forResource: "levels", withExtension: "json") else {
            return
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        
        guard let levels = try? decoder.decode([Level].self, from: Data(contentsOf: lvlUrl)) else {
            return
        }
        
        self.levels = levels
    }
    
}
