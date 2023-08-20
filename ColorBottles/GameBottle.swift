//
//  GameBottle.swift
//  ColorBottles
//
//  Created by Pavel Tsybulin on 14.08.2023.
//

import Foundation
import SpriteKit

class GameBottle : SKNode {
    private let BLOCK_HEGHT = 34.0
    private let BLOCK_BOTTOM_Y = -63.0
    private let SELECTED_BOTTLE_Y = 20.0
    var id : Int = 0
    private var blocks : [ColorBlock] = []
    private var selected = false
    
    var x : Double = 0 {
        didSet {
            self.position.x = self.x
        }
    }
    
    var y : Double = 0 {
        didSet {
            self.position.y = self.y
        }
    }
    
    var pos : CGPoint {
        get {
            return CGPoint(x: self.x, y: self.y)
        }
    }

    convenience init(with bottle: Bottle) {
        self.init()
        self.id = bottle.id
        self.name = "bottle_\(bottle.id)"
        
        for (j, clr) in bottle.blocks.enumerated() {
            let block = ColorBlock(with: clr)
            block.name = "block\(j)"
            block.position.y = BLOCK_BOTTOM_Y + Double(j) * BLOCK_HEGHT
            block.zPosition = 1
            self.blocks.append(block)
            self.addChild(block)
        }
        
        let btl = SKSpriteNode(imageNamed: "bottle")
        btl.name = "btl\(bottle.id)"
        btl.zPosition = 2
        self.addChild(btl)
    }
    
    func isEmpty() -> Bool {
        return self.blocks.count == 0
    }
    
    func isFull() -> Bool {
        return self.blocks.count == 4
    }
    
    func isSolved() -> Bool {
        return self.blocks.count == 4 &&
        self.blocks[1].waterColor == self.blocks[0].waterColor &&
        self.blocks[2].waterColor == self.blocks[0].waterColor &&
        self.blocks[3].waterColor == self.blocks[0].waterColor
    }
    
    func blockCount() -> Int {
        return self.blocks.count
    }
    
    func isSelected() -> Bool {
        return self.selected
    }
    
    func deselect() {
        self.selected = false
        self.position.y = self.y
    }
    
    func trySelect() -> Bool {
        if self.selected {
            return false
        }
        
        self.selected = true
        self.position.y = self.y + self.SELECTED_BOTTLE_Y
        return true
    }
    
    func topColor() -> String? {
        return self.blocks.last?.waterColor
    }
    
    func pop() -> ColorBlock? {
        guard !self.isEmpty() else {
            return nil
        }
        
        let block = self.blocks.removeLast()
        block.removeFromParent()
        return block
    }
    
    func push(block : ColorBlock) {
        guard self.blockCount() < 4 else {
            return
        }
        
        let j = self.blocks.count
        block.name = "block\(j)"
        block.position.y = BLOCK_BOTTOM_Y + Double(j) * BLOCK_HEGHT
        
        self.blocks.append(block)
        self.addChild(block)
    }
}

class ColorBlock : SKSpriteNode {
    var waterColor = "transparent"
    
    convenience init(with waterColor: String) {
        self.init(imageNamed: waterColor)
        self.waterColor = waterColor
    }
    
}
