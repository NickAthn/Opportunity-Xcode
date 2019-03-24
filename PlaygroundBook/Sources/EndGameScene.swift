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
    var button: SKNode! = nil
    var state: End!
    var viewController: GameViewController!
    
    convenience init?(fileNamed: String, state: End) {
        self.init(fileNamed: fileNamed)
        self.state = state
    }
    override func didMove(to view: SKView) {
        centerLabel = SKLabelNode()
        if #available(iOS 11.0, *) {centerLabel.preferredMaxLayoutWidth = view.frame.size.width - 50} else {}
        if #available(iOS 11.0, *) {centerLabel.numberOfLines = 0} else {}
        centerLabel.position = CGPoint(x:CGRect.init().midX, y:CGRect.init().midY)
        centerLabel.horizontalAlignmentMode = .center
        centerLabel.verticalAlignmentMode = .center
        centerLabel.fontName = Game.FontNames.messageInterface
        centerLabel.fontColor = .white
        centerLabel.fontSize = 30
        addChild(centerLabel)
        if state == End.won {
            centerLabel.text = Game.Endings.won
        } else if state ==  End.crashed{
            centerLabel.text = Game.Endings.crashed
        } else if state == End.noEnergy {
            centerLabel.text = Game.Endings.noEnergy
        }
        if state != End.won {
            // Create a simple red rectangle that's 100x44
            button = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 200, height: 40), cornerRadius: 10)
            
            // Put it in the center of the scene
            button.position = CGPoint(x:CGRect.init().midX - button.frame.width/2, y: centerLabel.frame.minY - 80);
            button.zPosition = 10
            button.name = "restart"

            self.addChild(button)
            
            let buttonLabel = SKLabelNode(text: "Restart")
            buttonLabel.position.x = button.frame.midX
            buttonLabel.position.y = button.frame.midY //- buttonLabel.frame.size.height/2
            buttonLabel.fontSize = 20
            buttonLabel.zPosition = 9
            buttonLabel.color = .white
            buttonLabel.verticalAlignmentMode = .center
            buttonLabel.horizontalAlignmentMode = .center
            addChild(buttonLabel)
        } else {
            let buttonLabel = SKLabelNode(text: "Go to the next page to continue the story")
            buttonLabel.position = CGPoint(x:CGRect.init().midX, y: centerLabel.frame.minY - 80);
            buttonLabel.fontSize = 20
            buttonLabel.zPosition = 15
            buttonLabel.color = .white
            buttonLabel.verticalAlignmentMode = .center
            buttonLabel.horizontalAlignmentMode = .center
            addChild(buttonLabel)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            if atPoint(touchLocation).name == "restart"{
                viewController.startGame()
            }
        }
    }
    
}

