//
//  GameEngine.swift
//  ColorBottles
//
//  Created by Pavel Tsybulin on 13.08.2023.
//

import Foundation
import SpriteKit

class GameEngine {
    struct Move {
        let from: Int
        let to : Int
        let cnt : Int
    }
    
    private let BOTTLE_WIDTH = 45.0
    private let BOTTLE_HEIGH = 164.0
    private let scene : GameScene
    private var currentLevel = 0
    private var bottles : [Int : GameBottle] = [:]
    private var stack : [Move] = []
    
    var auto = false
    
    init(with scene: GameScene) {
        self.scene = scene
    }
    
    func startLevel(lvl : Int) {
        self.bottles = [:]
        self.stack = []
        self.currentLevel = lvl
        self.scene.boardNode?.removeAllChildren()
        
        let level = GameManager.shared.levels[lvl]
        let totalBottles = level.bottles.count + level.emptyBottles
        let totalRows = (totalBottles + 4) / 4
        let boardHeigh = Double(totalRows) * BOTTLE_HEIGH + Double(totalRows - 1) * BOTTLE_WIDTH
        let yStep = BOTTLE_HEIGH + BOTTLE_WIDTH
        var y = boardHeigh / 2.0 - BOTTLE_HEIGH / 2.0
        
        var bn = 0
        
        for _ in 0..<totalRows {
            let bottlesInRow = min(4, totalBottles - bn)
            let xStep = BOTTLE_WIDTH * 2.0
            let rowWidth = Double(bottlesInRow) * BOTTLE_WIDTH + Double(bottlesInRow - 1) * BOTTLE_WIDTH
            var x = -(rowWidth / 2.0) + BOTTLE_WIDTH / 2.0

            for _ in 0..<bottlesInRow {
                let empty = Bottle(id: bn, blocks: [])
                let gameBottle = GameBottle(with: bn < level.bottles.count ? level.bottles[bn] : empty)
                self.bottles[gameBottle.id] = gameBottle
                gameBottle.x = x
                gameBottle.y = y
                self.scene.boardNode?.addChild(gameBottle)
                x += xStep
                bn += 1
            }
            
            y -= yStep
        }
    }
    
    func rollback() {
        guard self.stack.count > 0 else {
            return
        }
        
        let move = self.stack.removeLast()
        guard let from = self.bottles[move.from] else {
            return
        }
        guard let to = self.bottles[move.to] else {
            return
        }

//        print("rollback", from.id, "<- (\(move.cnt)) -", to.id)
        for _ in 0..<move.cnt {
            if let block = to.pop() {
                from.push(block: block)
            }
        }
    }
    
    private func pour(from : GameBottle, to : GameBottle, completition: @escaping () -> Void) {
        guard !from.isEmpty() else {
            self.scene.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: false))
            completition()
            return
        }
        
        guard !to.isFull() else {
            self.scene.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: false))
            completition()
            return
        }
        
        var newPosition = to.pos
        newPosition.y += (BOTTLE_HEIGH / 2.0)
        if to.x < from.x {
            newPosition.x += (BOTTLE_HEIGH / 2.0)
        } else {
            newPosition.x -= (BOTTLE_HEIGH / 2.0)
        }
        let angle = to.x < from.x ? 1.396263 : -1.396263
        
        var ok = to.isEmpty() || (from.topColor() == to.topColor() && !to.isFull())
        
        if ok {
            let AD = 0.5
            let toEmitter = SKEmitterNode(fileNamed: "pour")
            var cnt = 0
            from.run(SKAction.rotate(toAngle: angle, duration: AD))
            from.run(SKAction.move(to: newPosition, duration: AD)) {
                if let emitter = toEmitter {
                    emitter.particleTexture = SKTexture(imageNamed: from.topColor()!)
                    emitter.particlePosition = CGPoint(x: 0, y: self.BOTTLE_HEIGH * 0.5)
                    emitter.emissionAngle = 4.712389
                    to.addChild(emitter)
                }
                self.scene.run(SKAction.playSoundFileNamed("pour.wav", waitForCompletion: false))
                while to.isEmpty() || (from.topColor() == to.topColor() && !to.isFull()) {
                    ok = true
                    if let block = from.pop() {
                        to.push(block: block)
                        cnt += 1
                    }
                }

//                print("pour", from.id, "- (\(cnt)) ->", to.id)
                self.stack.append(Move(from: from.id, to: to.id, cnt: cnt))

                from.run(SKAction.rotate(toAngle: 0, duration: AD))
                from.run(SKAction.move(to: from.pos, duration: AD)) {
                    toEmitter?.removeFromParent()
                    completition()
                }
            }
        } else {
            completition()
        }

        
        if !ok {
            self.scene.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: false))
        }

    }
    
    private func deselect(bottle : GameBottle) {
        guard bottle.isSelected() else {
            return
        }
        
        bottle.deselect()
    }
    
    private func select(bottle : GameBottle) -> Bool {
        guard !bottle.isEmpty() else {
            self.scene.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: false))
            return false
        }
        
        if bottle.trySelect() {
            self.scene.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: false))
            return true
        }
        
        return false
    }
    
    private func isSolved() -> Bool {
        var solved = true
        self.bottles.values.forEach { bottle in
            if !bottle.isEmpty() {
                solved = solved && bottle.isSolved()
            }
        }
        return solved
    }
    
    var locked = false
    
    func bottleClick(bottle : GameBottle) {
        if let selectedBottle =  self.bottles.values.first(where: {$0.isSelected()}) {
            if selectedBottle == bottle {
                self.deselect(bottle: selectedBottle)
                return
            }

            self.locked = true

            self.pour(from: selectedBottle, to: bottle) {
                self.deselect(bottle: selectedBottle)
                if bottle.isSolved() {
                    bottle.run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.2)]))
                }

                if self.isSolved() {
                    self.scene.run(SKAction.playSoundFileNamed("victory.wav", waitForCompletion: false))
                    self.scene.boardNode?.run(SKAction.fadeOut(withDuration: 2.0), completion: {
                        self.scene.nextLevel()
                        self.scene.boardNode?.alpha = 1.0
                    })
                }

                self.locked = false
            }

            return
        }
        
        self.bottles.values.forEach { gameBottle in
            if gameBottle != bottle {
                self.deselect(bottle: gameBottle)
            }
        }
        
        if bottle.isSelected() {
            self.deselect(bottle: bottle)
            return
        }


        if !self.select(bottle: bottle) {
            return
        }
        
        guard self.auto else {
            return
        }
        
        let clr = bottle.topColor()
        var bs : [GameBottle] = []
        
        for b in self.bottles.values {
            if b != bottle && !b.isEmpty() && !b.isFull() && b.topColor() == clr && bottle.popable() <= b.pushable() {
                bs.append(b)
            }
        }
        
        if bs.count == 1 {
            self.bottleClick(bottle: bs[0])
            return
        } else if bs.count == 0 {
            for b in self.bottles.values {
                if b.isEmpty() {
                    self.bottleClick(bottle: b)
                    break
                }
            }
        }
    }
}
