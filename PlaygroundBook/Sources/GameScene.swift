//
//  GameScene.swift
//  spriteKit
//
//  Created by Nikolaos Athanasiou on 18/03/2019.
//  Copyright © 2019 athanasiou. All rights reserved.
//

import UIKit

import SpriteKit
import GameplayKit

public enum Side: Int {
    case left = -300
    case middle = 0
    case right = 300
}
public enum Move: Int {
    case left
    case right
    case stay
}

public class GameScene: SKScene {
    var background = SKSpriteNode(imageNamed: "MarsMap")
    
    var rover = SKSpriteNode()
    
    var roverMoveToSide: Move = Move.stay
    var roverSide: Side = Side.middle
    
    var canMove = false
    
    var centerPoint : CGFloat!
    var score = 0

    let roverMinimumX :CGFloat = -300
    let roverMaximumX : CGFloat = 300

    var countDown = 1
    var stopEverything = true
    var scoreText = SKLabelNode()
    
    override public func sceneDidLoad() {
        print("test")
    }
    
    override public func didMove(to view: SKView) {
        //background.zPosition = 0
        background.position = CGPoint(x: 0, y: 0 )
        //scene?.backgroundColor = UIColor(patternImage: UIImage(named: "MarsMap")!)
        addChild(background)

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setUp()
        physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(GameScene.createRoadStrip), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.startCountDown), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.traffic), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        let deadTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadTime) {
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.increaseScore), userInfo: nil, repeats: true)
        }
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        print("touch")
        if contact.bodyA.node?.name == "rover"{
            firstBody = contact.bodyA
        }else{
            firstBody = contact.bodyB
        }
        firstBody.node?.removeFromParent()
        afterCollision()
    }
    // TODO: - FINISH THIS
    public func afterCollision(){
//        if gameSettings.highScore < score{
//            gameSettings.highScore = score
//        }
//        let menuScene = SKScene(fileNamed: "GameMenu")!
//        menuScene.scaleMode = .aspectFill
//        view?.presentScene(menuScene, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(2)))
    
        print("Collision Detected")
    }
    
    
    // Needs refactoring
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            if touchLocation.x > centerPoint { // Left Click
                roverMoveToSide = .left
            } else { // Right Click
                roverMoveToSide = .right
            }
        }
        canMove = true
    }
    
    override public func update(_ currentTime: TimeInterval) {
        if canMove{
            moveTo(side: roverMoveToSide)
        }
        showRoadStrip()
    }
    
    
    // Needs refactoring
    func moveTo(side: Move){
        if side == .left {
            if roverSide == .left {
                // Do Nothing
            } else if roverSide == .middle {
                roverSide = .left
                rover.run(SKAction.moveBy(x: self.size.width / 3, y: 0, duration: 0.2))
                //rover.position.x -= -300
            } else if roverSide == .right {
                roverSide = .middle
                rover.run(SKAction.moveBy(x: self.size.width / 3, y: 0, duration: 0.2))
                //rover.position.x -= -300
            }
        }else if side == .right {
            if roverSide == .left {
                roverSide = .middle
                rover.run(SKAction.moveBy(x: self.size.width / -3, y: 0, duration: 0.2))
                //rover.position.x -= 300
            } else if roverSide == .middle {
                roverSide = .right
                rover.run(SKAction.moveBy(x: self.size.width / -3, y: 0, duration: 0.2))
                //rover.position.x -= 300
            } else if roverSide == .right {
                // Do Nothing
            }
        }
        roverMoveToSide = .stay
    }
    
    func setUp(){
        //rover = self.childNode(withName: "rover") as! SKSpriteNode
        rover = SKSpriteNode(imageNamed: "rover")
        rover.xScale = 0.75
        rover.yScale = 0.75
        rover.name = "rover"
        rover.zPosition = 10
        rover.position.x = 0
        rover.position.y = self.frame.minY + rover.size.height + 30
        rover.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: rover.size.width, height: rover.size.height))
        rover.physicsBody?.usesPreciseCollisionDetection = true
        rover.physicsBody?.isDynamic = true
        rover.physicsBody?.affectedByGravity = false
        
        centerPoint = self.frame.size.width / self.frame.size.height
        
        rover.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        rover.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER
        rover.physicsBody?.collisionBitMask = 0

        self.addChild(rover)

        let scoreBackGround = SKShapeNode(rect:CGRect(x:-self.size.width/2 + 70 ,y:self.size.height/2 - 130 ,width:180,height:80), cornerRadius: 20)
        scoreBackGround.zPosition = 4
        scoreBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        scoreBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scoreBackGround)
        
        scoreText.name = "score"
        scoreText.fontName = "AvenirNext-Bold"
        scoreText.text = "0"
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint(x: -self.size.width/2 + 160, y: self.size.height/2 - 110)
        scoreText.fontSize = 50
        scoreText.zPosition = 4
        addChild(scoreText)
    }


    @objc func startCountDown(){
        if countDown>0{
            if countDown < 4{
                let countDownLabel = SKLabelNode()
                countDownLabel.fontName = "AvenirNext-Bold"
                countDownLabel.fontColor = SKColor.white
                countDownLabel.fontSize = 300
                countDownLabel.text = String(countDown)
                countDownLabel.position = CGPoint(x: 0, y: 0)
                countDownLabel.zPosition = 300
                countDownLabel.name = "cLabel"
                countDownLabel.horizontalAlignmentMode = .center
                addChild(countDownLabel)
                
                let deadTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: deadTime, execute: {
                    countDownLabel.removeFromParent()
                })
            }
            countDown += 1
            if countDown == 4 {
                self.stopEverything = false
            }
        }
    }
    
    @objc func createRoadStrip(){
        let leftRoadStrip = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
        
        leftRoadStrip.strokeColor = SKColor.white
        leftRoadStrip.fillColor = SKColor.white
        leftRoadStrip.alpha = 0.4
        leftRoadStrip.name = "leftRoadStrip"
        leftRoadStrip.zPosition = 1
        leftRoadStrip.position.x = -155
        leftRoadStrip.position.y = 700
        addChild(leftRoadStrip)
        
        let rightRoadStrip = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
        rightRoadStrip.strokeColor = SKColor.white
        rightRoadStrip.fillColor = SKColor.white
        rightRoadStrip.alpha = 0.4
        rightRoadStrip.name = "rightRoadStrip"
        rightRoadStrip.zPosition = 10
        rightRoadStrip.position.x = 155
        rightRoadStrip.position.y = 700
        addChild(rightRoadStrip)
    }
    
    func showRoadStrip(){
        enumerateChildNodes(withName: "leftRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 30
        })

        enumerateChildNodes(withName: "rightRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 30
        })
        enumerateChildNodes(withName: "rock1", using: { (rover, stop) in
            let car = rover as! SKSpriteNode
            car.position.y -= 15
        })
        
        enumerateChildNodes(withName: "rock2", using: { (rover, stop) in
            let car = rover as! SKSpriteNode
            car.position.y -= 15
        })
        
        enumerateChildNodes(withName: "rock3", using: { (rover, stop) in
            let car = rover as! SKSpriteNode
            car.position.y -= 15
        })

    }

    
    @objc func traffic(){
        if !stopEverything{
            let trafficItem : SKSpriteNode!
            let randonNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
            switch Int(randonNumber) {
            case 1...3:
                trafficItem = SKSpriteNode(imageNamed: "rock1")
                trafficItem.name = "rock1"
                break
            case 4...7:
                trafficItem = SKSpriteNode(imageNamed: "rock2")
                trafficItem.name = "rock2"
                break
            case 8...10:
                trafficItem = SKSpriteNode(imageNamed: "rock3")
                trafficItem.name = "rock3"
                break
            default:
                trafficItem = SKSpriteNode(imageNamed: "rock1")
                trafficItem.name = "rock1"
            }
            trafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            trafficItem.zPosition = 10
            let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
            switch Int(randomNum) {
            case 1...3:
                trafficItem.position.x = -300
                break
            case 4...6:
                trafficItem.position.x = 0
                break
            case 7...10:
                trafficItem.position.x = 300
                break
            default:
                trafficItem.position.x = 0
            }
            
            trafficItem.position.y = 700
            trafficItem.physicsBody = SKPhysicsBody(circleOfRadius: trafficItem.size.height/2)
            trafficItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
            trafficItem.physicsBody?.collisionBitMask = 0
            trafficItem.physicsBody?.affectedByGravity = false
            trafficItem.physicsBody?.usesPreciseCollisionDetection = true
            addChild(trafficItem)
        }
    }
    
    @objc func removeItems(){
        for child in children{
            if child.position.y < -self.size.height - 100{
                child.removeFromParent()
            }
        }
    }
    
    @objc func increaseScore(){
        if !stopEverything{
            score += 1
            scoreText.text = String(score)
        }
    }


}

extension GameScene: SKPhysicsContactDelegate {
}

extension UIImage{
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
