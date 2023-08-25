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
    var autoNode : SKLabelNode?
    var engine : GameEngine?
    private var lvl = 0
    private let fg = UIImpactFeedbackGenerator(style: .light)

    override func didMove(to view: SKView) {
        self.boardNode = self.childNode(withName: "board")
        self.levelNode = self.childNode(withName: "top")?.childNode(withName: "level") as? SKLabelNode
        self.autoNode = self.childNode(withName: "bottom")?.childNode(withName: "auto") as? SKLabelNode
        self.engine = GameEngine(with: self)
        self.lvl = UserDefaults.standard.integer(forKey: "last_level")
        self.levelNode?.text = "Level \(self.lvl)"
        self.autoNode?.text = self.engine?.auto ?? false ? "A" : "M"
        self.engine?.startLevel(lvl: self.lvl)
        self.fg.prepare()
        
        self.showOptions()
    }
    
    private func showOptions() {
        let top = self.childNode(withName: "top")
        let bottom = self.childNode(withName: "bottom")
        top?.isHidden = false
        bottom?.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            top?.isHidden = true
            bottom?.isHidden = true
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        guard !(self.engine?.locked ?? false) else {
            return
        }
        
        let node = self.atPoint(pos)
        
        if node.name == "board" || node.name == "Scene" {
            self.showOptions()
            return
        }

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

        if node.name == "auto" {
            self.fg.impactOccurred()
            self.engine?.auto = !(self.engine?.auto ?? true)
            self.autoNode?.text = self.engine?.auto ?? false ? "A" : "M"
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
        self.showOptions()
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
