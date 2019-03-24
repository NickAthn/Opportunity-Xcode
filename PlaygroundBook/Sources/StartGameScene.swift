//
//  File.swift
//  Opportunity
//
//  Created by Nikolaos Athanasiou on 22/03/2019.
//

import Foundation
import SpriteKit

public protocol GameViewController {
    func startGame()
}

public class StartGameScene: SKScene {
    var viewController: GameViewController?
    let label = SKLabelNode()
    let nextLabel = SKLabelNode()
    var isAccessible = false
    var time: String = "120"
    
    public override func didMove(to view: SKView) {
        let text = "Last login: January 25, 2004 18:03:49 on ttys000 \n➜  ~"
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .left
        label.zPosition = 10
        
        label.position.x = self.frame.minX + 10
        label.position.y = self.frame.maxY - label.frame.size.height - 20
        label.fontSize = 15
        if #available(iOS 11.0, *) {label.numberOfLines = 0} else {}
        if #available(iOS 11.0, *) {label.preferredMaxLayoutWidth = view.frame.maxX} else {}
        label.fontName = Game.FontNames.terminalInterface
        label.fontColor = #colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)
        label.text = text
        addChild(label)
        
        nextLabel.verticalAlignmentMode = .top
        nextLabel.horizontalAlignmentMode = .left
        nextLabel.zPosition = 10
        nextLabel.position.x = 50
        nextLabel.position.y = label.frame.maxY - 18
        nextLabel.fontSize = 15
        if #available(iOS 11.0, *) {nextLabel.numberOfLines = 0} else {}
        if #available(iOS 11.0, *) {nextLabel.preferredMaxLayoutWidth = view.frame.maxX} else {}
        nextLabel.fontName = Game.FontNames.terminalInterface
        nextLabel.fontColor = #colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)
        nextLabel.text = "connect -i Opportunity"
        addChild(nextLabel)

        nextLabel.startTyping(0.01, completion: nil)
    }
    public init(size: CGSize, viewController: GameViewController) {
        super.init(size: size)
        self.viewController = viewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func connect(){
        let lastLabel = SKLabelNode()
        
        lastLabel.fontName = Game.FontNames.terminalInterface
        if #available(iOS 11.0, *) {lastLabel.numberOfLines = 0} else {}
        if #available(iOS 11.0, *) {lastLabel.preferredMaxLayoutWidth = view?.frame.maxX ?? 0} else {}
        lastLabel.verticalAlignmentMode = .top
        lastLabel.horizontalAlignmentMode = .left
        lastLabel.fontColor = nextLabel.fontColor
        lastLabel.fontSize = 15
        lastLabel.position.x = label.position.x
        lastLabel.position.y = nextLabel.position.y - 18
        lastLabel.text = "Connecting...\nConnection Succesfull!\nAccesibilityMode: \(isAccessible)\nTime: \(time)\nPlanet: Mars\n➜  ~ Activate Opportunity\n...................................................................................................."
        self.addChild(lastLabel)
        lastLabel.startTyping(0.02, completion: {
            self.viewController?.startGame()
        })
    }
}
