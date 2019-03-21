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
import AudioToolbox


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
    // Background Image
    var background = SKSpriteNode(imageNamed: "MarsMap")
    
    // Rover and its Properties
    var rover = SKSpriteNode()

    var roverMoveToSide: Move = Move.stay
    var roverSide: Side = Side.middle
    
    var canMove = false
    
    var centerPoint : CGFloat!
    
    let roverMinimumX :CGFloat = -300
    let roverMaximumX : CGFloat = 300

    
    var countDown = 1
    var stopEverything = true
    
    // Score Label
    var scoreLabel = SKLabelNode()
    var score = 0

    // Lives Label
    let energyLabel = SKLabelNode()
    var energy = 100
    
    let gameTime = 60
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
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 1.8)), target: self, selector: #selector(GameScene.traffic), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        
        let deadTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadTime) {
            Timer.scheduledTimer(timeInterval: TimeInterval(self.gameTime/15), target: self, selector: #selector(GameScene.increaseScore), userInfo: nil, repeats: true)
            Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.loseEnergy), userInfo: nil, repeats: true)

        }
    }
    
    // MARK: - Collision Logic
    public func didBegin(_ contact: SKPhysicsContact) {
        var bodyToRemove = SKPhysicsBody()
        print("touch")
        UIDevice.vibrate()
        
        if contact.bodyA.node?.name == "rover"{
            if contact.bodyB.node?.name == "energyOrb" {
                bodyToRemove = contact.bodyB
                addEnergy()
            } else {
                
                bodyToRemove = contact.bodyA
                loseEnergyWith(amount: 10)
                if energy == 0 {
                    bodyToRemove = contact.bodyA
                } else {
                    bodyToRemove = contact.bodyB
                }
            }
        }else{
            if contact.bodyA.node?.name == "energyOrb" {
                bodyToRemove = contact.bodyA
                addEnergy()
            } else {
                
                loseEnergyWith(amount: 10)
                if energy == 0 {
                    bodyToRemove = contact.bodyB
                } else {
                    bodyToRemove = contact.bodyA
                }
            }
        }
        bodyToRemove.node?.removeFromParent()
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
                rover.run(SKAction.moveBy(x: self.size.width / 3, y: 0, duration: 0.1))
                //rover.position.x -= -300
            } else if roverSide == .right {
                roverSide = .middle
                rover.run(SKAction.moveBy(x: self.size.width / 3, y: 0, duration: 0.1))
                //rover.position.x -= -300
            }
        }else if side == .right {
            if roverSide == .left {
                roverSide = .middle
                rover.run(SKAction.moveBy(x: self.size.width / -3, y: 0, duration: 0.1))
                //rover.position.x -= 300
            } else if roverSide == .middle {
                roverSide = .right
                rover.run(SKAction.moveBy(x: self.size.width / -3, y: 0, duration: 0.1))
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

        let staticScoreLabel = SKLabelNode()
        staticScoreLabel.fontName = "AvenirNext-Bold"
        staticScoreLabel.text = "Years"
        staticScoreLabel.fontColor = SKColor.white
        staticScoreLabel.position = CGPoint(x: -self.size.width/2 + 160, y: self.size.height/2 - 110)
        staticScoreLabel.fontSize = 50
        staticScoreLabel.zPosition = 4
        addChild(staticScoreLabel)
        

        scoreLabel.name = "score"
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.text = "0"
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: -self.size.width/2 + 160, y: staticScoreLabel.position.y - 70)
        scoreLabel.fontSize = 50
        scoreLabel.zPosition = 4
        addChild(scoreLabel)
        
        let scoreBackGround = SKShapeNode(rect:CGRect(x: scoreLabel.position.x - 90 ,y: scoreLabel.position.y - 20 ,width:180,height:80), cornerRadius: 12)
        scoreBackGround.zPosition = 4
        scoreBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        scoreBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scoreBackGround)
        
        let staticLivesLabel = SKLabelNode()
        staticLivesLabel.fontName = "AvenirNext-Bold"
        staticLivesLabel.text = "Energy"
        staticLivesLabel.fontColor = SKColor.white
        staticLivesLabel.position = CGPoint(x: self.frame.maxX - 160 , y: self.size.height/2 - 110)
        staticLivesLabel.fontSize = 50
        staticLivesLabel.zPosition = 4
        addChild(staticLivesLabel)

        energyLabel.name = "energy"
        energyLabel.text = "100%"
        energyLabel.fontName = "AvenirNext-Bold"
        energyLabel.fontColor = SKColor.white
        energyLabel.position = CGPoint(x:  self.frame.maxX - 160 , y: staticLivesLabel.position.y - 70)
        energyLabel.fontSize = 50
        energyLabel.zPosition = 4
        addChild(energyLabel)
        
        let livesBackground = SKShapeNode(rect:CGRect(x: energyLabel.position.x - 90 ,y: energyLabel.position.y - 20 ,width:180,height:80), cornerRadius: 12)
        livesBackground.zPosition = 4
        livesBackground.fillColor = SKColor.black.withAlphaComponent(0.3)
        livesBackground.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(livesBackground)
        

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
        
        enumerateChildNodes(withName: "energyOrb", using: { (rover, stop) in
            let car = rover as! SKSpriteNode
            car.position.y -= 15
        })


    }

    
    @objc func traffic(){
        if !stopEverything {
            let randonNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 100)
            switch Int(randonNumber){
            case 1...20:
                throwEnergy()
            default:
                throwRock()
            }
        }
    }
    func throwEnergy(){
        let energy : SKSpriteNode!
        energy = SKSpriteNode(imageNamed: "energyOrb")
        energy.name = "energyOrb"

        energy.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        energy.zPosition = 10

        let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
        switch Int(randomNum) {
        case 1...3:
            energy.position.x = self.size.width / 3
            break
        case 4...6:
            energy.position.x = 0
            break
        case 7...10:
            energy.position.x = self.size.width / -3
            break
        default:
            energy.position.x = 0
        }
        
        energy.run(SKAction.rotate(byAngle: 10, duration: 10))
        energy.position.y = 700
        energy.physicsBody = SKPhysicsBody(circleOfRadius: energy.size.height/2)
        energy.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
        energy.physicsBody?.collisionBitMask = 0
        energy.physicsBody?.affectedByGravity = false
        energy.physicsBody?.usesPreciseCollisionDetection = true
        addChild(energy)
    }
    func throwRock(){
        let rock : SKSpriteNode!
        let randonNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
        switch Int(randonNumber) {
        case 1...3:
            rock = SKSpriteNode(imageNamed: "rock1")
            rock.name = "rock1"
            break
        case 4...7:
            rock = SKSpriteNode(imageNamed: "rock2")
            rock.name = "rock2"
            break
        case 8...10:
            rock = SKSpriteNode(imageNamed: "rock3")
            rock.name = "rock3"
            break
        default:
            rock = SKSpriteNode(imageNamed: "rock1")
            rock.name = "rock1"
        }
        rock.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rock.zPosition = 10
        
        let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
        switch Int(randomNum) {
        case 1...3:
            rock.position.x = self.size.width / 3
            break
        case 4...6:
            rock.position.x = 0
            break
        case 7...10:
            rock.position.x = self.size.width / -3
            break
        default:
            rock.position.x = 0
        }
        
        rock.run(SKAction.rotate(byAngle: 10, duration: 10))
        rock.position.y = 700
        rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.size.height/2)
        rock.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
        rock.physicsBody?.collisionBitMask = 0
        rock.physicsBody?.affectedByGravity = false
        rock.physicsBody?.usesPreciseCollisionDetection = true
        addChild(rock)

    }
    
    func addEnergy(){
        energy += 5
    }
    
    func loseEnergyWith(amount: Int){
        if !stopEverything{
            if energy - amount < 0 || energy == 0{ // END GAME
                energy = 0
                endGame()
            } else {
                energy -= amount
            }
            energyLabel.text = "\(energy)%"
        }

    }
    @objc func loseEnergy(){
        if !stopEverything{
            let valueToDecrease = (100/(gameTime)) // GameTime/ THe amout of time the user will finish his power
            if energy - valueToDecrease < 0 || energy == 0{ // END GAME
                energy = 0
                endGame()
            } else {
                energy -= valueToDecrease
            }
            energyLabel.text = "\(energy)%"
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
            scoreLabel.text = String(score)
        }
    }

    func endGame(){
        
    }

}

extension GameScene: SKPhysicsContactDelegate {
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

public func gameView() -> SKView {
    let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 1050, height: 1472))
    
    let scene = GameScene(size: CGSize(width: 1050, height: 1472))
    scene.scaleMode = .fill
    sceneView.presentScene(scene)
    return sceneView
}
