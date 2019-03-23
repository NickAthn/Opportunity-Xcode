//
//  EndGameScene.swift
//  Opportunity
//
//  Created by Nikolaos Athanasiou on 21/03/2019.
//

import Foundation
import SpriteKit

class EndGameScene: SKScene{
    var centerLabel = SKLabelNode()
    var state: State!
    
    convenience init?(fileNamed: String, state: State) {
        self.init(fileNamed: fileNamed)
        self.state = state
    }
    override func didMove(to view: SKView) {
//        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        startGame = self.childNode(withName: "startGame") as! SKLabelNode
        centerLabel = self.childNode(withName: "centerLabel") as! SKLabelNode
        if state == State.won {
            centerLabel.text = "Sand Storm Incoming. Oppy turns into hibernation mode to save energy."
            if #available(iOS 11.0, *) {
                centerLabel.preferredMaxLayoutWidth = view.frame.size.width - 50
            } else {
                // Fallback on earlier versions
            }
            centerLabel.position = CGPoint(x: 0, y: 0 - centerLabel.frame.size.height/2)
        } else {
            centerLabel.text = "You crashed Oppy!"
            centerLabel.position = CGPoint(x: 0, y: 0 - centerLabel.frame.size.height/2)

        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            if atPoint(touchLocation).name == "startGame"{
//                let gameScene = SKScene(fileNamed: "GameScene")!
//                gameScene.scaleMode = .aspectFill
//                view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(2)))
            }
        }
    }
    
}

