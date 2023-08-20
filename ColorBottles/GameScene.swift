//
//  GameScene.swift
//  ColorBottles
//
//  Created by Pavel Tsybulin on 12.08.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var boardNode : SKNode?
    var levelNode : SKLabelNode?
    var engine : GameEngine?
    private var lvl = 0
    private let fg = UIImpactFeedbackGenerator(style: .light)

    override func didMove(to view: SKView) {
        self.boardNode = self.childNode(withName: "board")
        self.levelNode = self.childNode(withName: "top")?.childNode(withName: "level") as? SKLabelNode
        self.engine = GameEngine(with: self)
        self.lvl = UserDefaults.standard.integer(forKey: "last_level")
        self.levelNode?.text = "Level \(self.lvl)"
        self.engine?.startLevel(lvl: self.lvl)
        self.fg.prepare()
    }
    
    func touchDown(atPoint pos : CGPoint) {
        let node = self.atPoint(pos)

        if node.name == "back" {
            self.fg.impactOccurred()
            self.fg.prepare()
            self.prevLevel()
            return
        }
        
        if node.name == "forward" {
            self.fg.impactOccurred()
            self.fg.prepare()
            self.nextLevel()
            return
        }

        if node.name == "reset" {
            self.fg.impactOccurred()
            self.fg.prepare()
            self.engine?.startLevel(lvl: self.lvl)
            return
        }
        
        if node.name == "rollback" {
            self.fg.impactOccurred()
            self.fg.prepare()
            self.engine?.rollback()
            return
        }

        let nodes = self.nodes(at: pos)
        
        for node in nodes {
            if let bottle = node as? GameBottle {
                self.engine?.bottleClick(bottle: bottle)
                return
            }
        }
    }
    
    public func nextLevel() {
        self.lvl += 1
        if self.lvl >= GameManager.shared.levels.count {
            self.lvl = 0
        }
        
        UserDefaults.standard.set(self.lvl, forKey: "last_level")
        
        self.levelNode?.text = "Level \(self.lvl)"
        self.engine?.startLevel(lvl: self.lvl)
    }
    
    private func prevLevel() {
        self.lvl -= 1
        if self.lvl < 0 {
            self.lvl = GameManager.shared.levels.count - 1
        }

        UserDefaults.standard.set(self.lvl, forKey: "last_level")
        
        self.levelNode?.text = "Level \(self.lvl)"
        self.engine?.startLevel(lvl: self.lvl)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
