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

public enum End {
    case crashed
    case noEnergy
    case won
}


protocol CanReceiveTransitionEvents {
    func viewWillTransition(to size: CGSize)
}

public class GameScene: SKScene, SKPhysicsContactDelegate, CanReceiveTransitionEvents {
    func viewWillTransition(to size: CGSize) {
        
    }
    
    // Background Image
    var background = SKSpriteNode(imageNamed: "marsMap")
    let backgroundSound = SKAudioNode(fileNamed: Sounds.ambient)
    let sandStormEmmiter = SKEmitterNode(fileNamed: "SandStorm.sks")
    // Rover and its Properties
    var rover = SKSpriteNode()
    var isHit = false
    
    var canMove = false
    var centerPoint : CGFloat!
    
    
    var countDown = 1
    var stopEverything = true
    
    // Rocks
    var possibleRocks = ["rock1", "rock2", "rock3"]

    // Score Label
    var scoreLabel = SKLabelNode()
    var year = 2004

    // Lives Label
    let energyLabel = SKLabelNode()
    var energy = 100
    
    // Transmissions
    var currentTransmissions: [SKLabelNode] = []
    var satellite = SKSpriteNode()
    
    let gameTime = 100
    var gameSpeed: CGFloat = 15
    var maxTime = 1.8
    var minTime = 0.8
    public func startGame(){
        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.startCountDown), userInfo: nil, repeats: true)
        addChild(backgroundSound)
        backgroundSound.autoplayLooped = true
        endGame(state: .won)
    }
    
    
    override public func didMove(to view: SKView) {
        
        background.zPosition = Game.PositionZ.background
        background.position = CGPoint(x: 0, y: 0 )
        background.yScale = 2
        background.xScale = 2
        
        addChild(background)
        
        sandStormEmmiter?.zPosition = Game.PositionZ.enviromentalChanges
        sandStormEmmiter?.position = CGPoint(x: 0, y: view.frame.maxY)
        sandStormEmmiter?.particlePositionRange = CGVector(dx: view.frame.width*2, dy: 0)
        
        let changeVolume = SKAction.changeVolume(to: 0.4, duration: 0.3)
        backgroundSound.run(changeVolume)

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setUp()
        physicsWorld.contactDelegate = self
        
        startGame()
        Timer.scheduledTimer(timeInterval: Double.random(in: minTime...maxTime), target: self, selector: #selector(GameScene.traffic), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        
        let deadTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadTime) {
            Timer.scheduledTimer(timeInterval: TimeInterval(self.gameTime/15), target: self, selector: #selector(GameScene.incrementYear), userInfo: nil, repeats: true)
            Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.loseEnergy), userInfo: nil, repeats: true)

        }
    }
    
    // MARK: - Collision Logic
    public func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if secondBody.node?.name == "rock" && isHit == false {
            roverDidCollideWithRock(rover: firstBody.node as! SKSpriteNode, rock: secondBody.node as! SKSpriteNode)
        } else if secondBody.node?.name == "energyOrb" {
            roverDidCollideWithEnergyOrb(rover: firstBody.node as! SKSpriteNode, energyOrb: secondBody.node as! SKSpriteNode)
        }
    }
    func roverDidCollideWithEnergyOrb(rover: SKSpriteNode, energyOrb: SKSpriteNode) {
        self.run(SKAction.playSoundFileNamed(Sounds.charge, waitForCompletion: false))
        let fadeGreen = SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0.5)
        let fadeWhite = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 0.5)
        energyLabel.run(SKAction.repeat(SKAction.sequence([fadeGreen, fadeWhite]), count: 1), withKey: "colorChange")
        energyOrb.removeFromParent()
        addEnergy()
    }
    func roverDidCollideWithRock(rover: SKSpriteNode, rock: SKSpriteNode) {
        isHit = true
        let fadeRed = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.3)
        let fadeWhite = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 0.3)
        energyLabel.run(SKAction.repeat(SKAction.sequence([fadeRed, fadeWhite]), count: 2), withKey: "colorChange")
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.3)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.3)
        let animation = SKAction.repeat(SKAction.sequence([fadeOut, fadeIn]), count: 3)
        rover.run(animation, completion: {
            self.isHit = false
        })
        self.run(SKAction.playSoundFileNamed(Sounds.crash, waitForCompletion: false))
        rock.removeFromParent()
    }
    
    // MARK: - Touch Logic
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        for touch in touches{
            let touchLocation = touch.location(in: self)
            
            moveRover(to: touchLocation)
        }
        canMove = true
    }
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            moveRover(to: touchLocation)
        }
        canMove = true
    }
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            if touch.tapCount > 1 {
                print("fire")
                fireProjectile()
            }
            let touchLocation = touch.location(in: self)
            moveRover(to: touchLocation)
        }
        canMove = true
    }
    
    
    func moveRover(to location: CGPoint){
        let distance =  abs((Double(location.x - rover.position.x)))
        let speed: Double = 600
        if location.x > (self.size.width)/2 || location.x < -((self.size.width)/2) {
            
        } else {
        let move = SKAction.moveTo(x: location.x, duration: distance/speed)
            
            // Move Player with steady speed of "speed" points
    //        if location.x - rover.position.x > 0 {
    //            rover.run(SKAction.rotate(toAngle: -0.5, duration: 0.5))
    //        } else {
    //            rover.run(SKAction.rotate(toAngle: 0.5, duration: 0.5))
    //        }
            rover.run(move) {
    //            self.rover.run(SKAction.rotate(toAngle: 0, duration: 0.5), withKey: "still")
            }
        }
    }
    
    override public func update(_ currentTime: TimeInterval) {
        if year == 2018 && energy > 0 {
            endGame(state: End.won)
        } else if energy == 0 {
            endGame(state: End.noEnergy)
        }
        throwProjectiles()
    }
    
    func transmissionManager() {
        switch year {
        case 2004: addIncomingTransmission(text: "You just landed on the Eagle crater of Mars")
        case 2005: addIncomingTransmission(text: "Whats that? You find a meteorite! It's name? Heat Shield Rock.")
        case 2007: addIncomingTransmission(text: "NEW FIRMWARE! Both you and your brother Spirit were just updated!")
        case 2008: addIncomingTransmission(text: "Dust Storm Incoming. Sadly we will have to enter into radio silence to save energy. Good luck Rovers.")
        case 2010: addIncomingTransmission(text: "Spirit is not answering.")
        case 2011: addIncomingTransmission(text: "Oppy, sadly your brother is lost or....you are now alone.")
        case 2012: addIncomingTransmission(text: "Good News. We a sent a new rover to your way named Curiosity. Say hey!")
        case 2014: addIncomingTransmission(text: "Op#F#$R HE#R DSodyma#R $....MEMORY MALFUNCTION!")
        case 2015: addIncomingTransmission(text: "Happy 13 years anniversary!")
        case 2018: addIncomingTransmission(text: "Dust Storm Incoming...")
        default: break
        }
    }
    
    func addIncomingTransmission(text: String){
        self.run(SKAction.playSoundFileNamed(Sounds.incomingTransmission, waitForCompletion: false))

        let transmissionLabel = SKLabelNode(text: "")
        transmissionLabel.text = text
        transmissionLabel.horizontalAlignmentMode = .left
        transmissionLabel.verticalAlignmentMode = .top
        transmissionLabel.fontName = Game.FontNames.helveticaNeue.bold//"AvenirNext-Regular"
        
        transmissionLabel.fontColor = #colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)
        if #available(iOS 11.0, *) {transmissionLabel.numberOfLines = 0} else {}
        if #available(iOS 11.0, *) {transmissionLabel.preferredMaxLayoutWidth = self.size.width/2} else {}
        
        transmissionLabel.fontSize = 35
        transmissionLabel.zPosition = Game.PositionZ.userInterface
        addChild(transmissionLabel)
        transmissionLabel.position = CGPoint(x: -self.size.width/2 + 30, y: self.size.height/2 - 280)

        if currentTransmissions.isEmpty {
            
        } else {
            var counter: CGFloat = 0
            for transmission in currentTransmissions {
                counter += 0.2
                if #available(iOS 11.0, *) {transmission.run(SKAction.moveBy(x: 0, y: -transmissionLabel.frame.height, duration: 0.1))} else {}
            }
        }
        
        if currentTransmissions.count >= 3 {
                currentTransmissions.first?.run(SKAction.fadeOut(withDuration: 0.3), completion: {
                    self.currentTransmissions.first?.removeFromParent()
                })
        }

        currentTransmissions.append(transmissionLabel)
        
        transmissionLabel.startTyping(0.01) {
            transmissionLabel.run(SKAction.sequence([SKAction.wait(forDuration: 5),SKAction.fadeOut(withDuration: 1)]))
        }
        
        // Satellite Icon Animation
        satellite.run(SKAction.repeat(SKAction.sequence([SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0.3),SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 0.3)]), count: 1))
        let rotateLeft = SKAction.rotate(toAngle: -0.1, duration: 0.1)
        let rotateRight = SKAction.rotate(toAngle: 0.1, duration: 0.1)
        let defaultRotation = SKAction.rotate(toAngle: 0, duration: 0.1)
        let rotationSequence = SKAction.sequence([rotateRight, rotateLeft])
        let sequence = SKAction.sequence([SKAction.repeat(rotationSequence, count: 2), defaultRotation ])
        satellite.run(sequence)
    }
    
    
    // MARK: - Setting up view
    func setUp(){
        rover = SKSpriteNode(imageNamed: "rover")
        rover.xScale = 0.75
        rover.yScale = 0.75
        rover.name = "rover"
        rover.zPosition = Game.PositionZ.actors
        rover.position.x = 0
        rover.position.y = self.frame.minY + rover.size.height + 30
        rover.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: rover.size.width, height: rover.size.height))
        rover.physicsBody?.usesPreciseCollisionDetection = true
        rover.physicsBody?.isDynamic = true
        rover.physicsBody?.affectedByGravity = false
        
        
        centerPoint = self.frame.size.width / self.frame.size.height
        
        rover.physicsBody?.categoryBitMask = ColliderType.ROVER_COLLIDER
        rover.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER
        rover.physicsBody?.collisionBitMask = 0

        self.addChild(rover)

        let staticScoreLabel = SKLabelNode()
        staticScoreLabel.fontName = "AvenirNext-Bold"
        staticScoreLabel.text = "Year"
        staticScoreLabel.fontColor = SKColor.white
        staticScoreLabel.position = CGPoint(x: -self.size.width/2 + 160, y: self.size.height/2 - 110)
        staticScoreLabel.fontSize = 50
        staticScoreLabel.zPosition = Game.PositionZ.userInterface
        addChild(staticScoreLabel)
        

        scoreLabel.name = "score"
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.text = "2004"
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: -self.size.width/2 + 160, y: staticScoreLabel.position.y - 70)
        scoreLabel.fontSize = 50
        scoreLabel.zPosition = Game.PositionZ.userInterface
        addChild(scoreLabel)
        
        let scoreBackGround = SKShapeNode(rect:CGRect(x: scoreLabel.position.x - 90 ,y: scoreLabel.position.y - 20 ,width:180,height:80), cornerRadius: 12)
        scoreBackGround.zPosition = Game.PositionZ.userInterfaceBackground
        scoreBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        scoreBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scoreBackGround)
        
        let staticLivesLabel = SKLabelNode()
        staticLivesLabel.fontName = "AvenirNext-Bold"
        staticLivesLabel.text = "Energy"
        staticLivesLabel.fontColor = SKColor.white
        staticLivesLabel.position = CGPoint(x: self.frame.maxX - 160 , y: self.size.height/2 - 110)
        staticLivesLabel.fontSize = 50
        staticLivesLabel.zPosition = Game.PositionZ.userInterface
        addChild(staticLivesLabel)

        energyLabel.name = "energy"
        energyLabel.text = "100%"
        energyLabel.fontName = "AvenirNext-Bold"
        energyLabel.fontColor = SKColor.white
        energyLabel.position = CGPoint(x:  self.frame.maxX - 160 , y: staticLivesLabel.position.y - 70)
        energyLabel.fontSize = 50
        energyLabel.zPosition = Game.PositionZ.userInterface
        addChild(energyLabel)
        
        let livesBackground = SKShapeNode(rect:CGRect(x: energyLabel.position.x - 90 ,y: energyLabel.position.y - 20 ,width:180,height:80), cornerRadius: 12)
        livesBackground.zPosition = Game.PositionZ.userInterfaceBackground
        livesBackground.fillColor = SKColor.black.withAlphaComponent(0.3)
        livesBackground.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(livesBackground)
        
        satellite = SKSpriteNode(texture: SKTexture(imageNamed: "satellite"))
        satellite.name = "sat"
        satellite.position = CGPoint(x:  -self.size.width/2 + 320 , y: scoreLabel.position.y + 15)
        satellite.xScale = 0.8
        satellite.yScale = 0.8
        satellite.zPosition = Game.PositionZ.userInterface
        satellite.colorBlendFactor = 1
        satellite.color = .white
        addChild(satellite)
        transmissionManager()
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
                countDownLabel.zPosition = Game.PositionZ.userInterface
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
    
    func throwProjectiles(){
        enumerateChildNodes(withName: "rock", using: { (rover, stop) in
            let rover = rover as! SKSpriteNode
            rover.position.y -= self.gameSpeed
        })
        enumerateChildNodes(withName: "energyOrb", using: { (rover, stop) in
            let rover = rover as! SKSpriteNode
            rover.position.y -= self.gameSpeed-5
        })
    }

    
    @objc func traffic(){
        if !stopEverything {
            let random = GKShuffledDistribution.d20()
            switch Int(random.nextInt()){
            case 1...5:
                addEnergyOrb()
            default:
                addRock()
            }
        }
    }
    
    func addEnergyOrb(){
        let energy : SKSpriteNode!
        energy = SKSpriteNode(imageNamed: "energyOrb")
        energy.name = "energyOrb"

        energy.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        energy.zPosition = Game.PositionZ.actors

        let viewMaxX = (view?.frame.size.width ?? 0)/2

        let maxLeftValue = Int(-(viewMaxX))
        let maxRightValue = Int(viewMaxX)
        let randomPosition = GKRandomDistribution(lowestValue: maxLeftValue , highestValue: maxRightValue)
        let position = CGFloat(randomPosition.nextInt())
        energy.position = CGPoint(x: position, y: self.frame.size.height + energy.size.height)

        energy.run(SKAction.rotate(byAngle: CGFloat(GKRandomDistribution.init(lowestValue: -10, highestValue: 10).nextInt()), duration: 10))
        energy.physicsBody = SKPhysicsBody(circleOfRadius: energy.size.height/2)
        energy.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
        energy.physicsBody?.collisionBitMask = 0
        energy.physicsBody?.affectedByGravity = false
        energy.physicsBody?.usesPreciseCollisionDetection = true
        
        energy.addGlow(radius: 60)
        addChild(energy)
    }
    func addRock(){
        possibleRocks = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleRocks) as! [String]
        let rock = SKSpriteNode(imageNamed: possibleRocks.first!)
        rock.name = "rock"
        
        let viewMaxX = (view?.frame.size.width ?? 0)/2
        
        let maxLeftValue = Int(-(viewMaxX))
        let maxRightValue = Int(viewMaxX)
        let randomPosition = GKRandomDistribution(lowestValue: maxLeftValue , highestValue: maxRightValue)
        let position = CGFloat(randomPosition.nextInt())
        rock.position = CGPoint(x: position, y: self.frame.size.height + rock.size.height)
 
        rock.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rock.zPosition = Game.PositionZ.actors
        let randomSizeIncrease = CGFloat(GKRandomDistribution(lowestValue: -30, highestValue: 50).nextInt())
        rock.scale(to: CGSize(width: rock.size.width + randomSizeIncrease  , height: rock.size.height + randomSizeIncrease ))
        
        rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.size.height/2)
        rock.physicsBody?.isDynamic = true
        
        rock.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
        rock.physicsBody?.collisionBitMask = 0
        rock.physicsBody?.affectedByGravity = false
        addChild(rock)
        
        
        rock.run(SKAction.rotate(byAngle:CGFloat(GKRandomDistribution.init(lowestValue: -10, highestValue: 10).nextInt()), duration: 10))
    }
    func fireProjectile() {
        self.run(SKAction.playSoundFileNamed("fireProjectile.mp3", waitForCompletion: false))
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = rover.position
        projectile.position.y += 5
        projectile.name = "projectile"
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width / 2)
        projectile.physicsBody?.isDynamic = true
        
        projectile.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER_1
        projectile.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER
        projectile.physicsBody?.collisionBitMask = 0
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(projectile)
        
        let animationDuration:TimeInterval = 0.3
        
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: rover.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        projectile.run(SKAction.sequence(actionArray))
    }

    func addEnergy(){
        if energy + 8 > 100 {
            energy = 100
        } else {
            energy += 8
        }
    }
    
    func loseEnergyWith(amount: Int){
        if !stopEverything{
            if energy - amount < 0 || energy == 0{ // END GAME
                energy = 0
                endGame(state: .crashed)
            } else {
                energy -= amount
            }
            energyLabel.text = "\(energy)%"
        }

    }
    @objc func loseEnergy(){
//        if !stopEverything{
//            let valueToDecrease = (100/(gameTime)) // GameTime/ THe amout of time the user will finish his power
//            if energy - valueToDecrease < 0 || energy == 0{ // END GAME
//                energy = 0
//            } else {
//                energy -= valueToDecrease
//            }
//            energyLabel.text = "\(energy)%"
//        }
    }
    
    @objc func removeItems(){
        for child in children{
            if child.position.y < -self.size.height - 100{
                child.removeFromParent()
            }
        }
    }
    
    @objc func incrementYear(){
        if !stopEverything{
            year += 1
            scoreLabel.text = String(year)
            transmissionManager()
            difficulty()
        }
    }
    
    func addSandstorm(for time: TimeInterval = 15){
        let sandStorm = SKEmitterNode(fileNamed: "SandStorm.sks")!
        sandStorm.zPosition = Game.PositionZ.enviromentalChanges
        sandStorm.position = CGPoint(x: -40, y: (view?.frame.maxY ?? 0) + 40)
        sandStorm.particlePositionRange = CGVector(dx:((view?.frame.width)!)*2, dy: 0)
        sandStorm.emissionAngle = 40
        addChild(sandStorm)

        let wait = SKAction.wait(forDuration: time)
        let fadeOut = SKAction.fadeOut(withDuration: 5)
        let remove = SKAction.removeFromParent()
        
        sandStorm.run(SKAction.sequence([wait,fadeOut,remove]))
        
    }
    
    func difficulty() {
        if year == 2019 || year == 2012 || year == 2014 || year == 2015 || year == 2016 {
            gameSpeed += 3
            maxTime -= 2
            minTime -= 1
        }
    }

    func endGame(state: End){
        let endScene = EndGameScene(fileNamed: "EndGameScene.sks", state: state)!
        if state == .won {
                addSandstorm()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(30), execute: {
                    self.view?.presentScene(endScene, transition: SKTransition.crossFade(withDuration: 1))
                })

        } else if state == .crashed {
            view?.presentScene(endScene, transition: SKTransition.crossFade(withDuration: 1))
        } else if state == .noEnergy {
            view?.presentScene(endScene, transition: SKTransition.crossFade(withDuration: 1))

        }
    }

}


public func gameView() -> SKView {
    let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 1050, height: 1472))
    
    let scene = GameScene(size: CGSize(width: 1050, height: 1472))
    scene.scaleMode = .fill
    sceneView.presentScene(scene)
    return sceneView
}

public struct ColliderType {
    static let ROVER_COLLIDER : UInt32 = 0
    
    static let ITEM_COLLIDER : UInt32 = 1
    static let ITEM_COLLIDER_1 : UInt32 = 2
}

extension SKLabelNode{
    func startTyping(_ duration:TimeInterval, completion:(()->Void)?){
        guard let text = self.text else{return}
        
        self.text = ""
        var index = 0
        var block:(() -> Void)!
        block = {
            index += 1
            if index > text.count{
                completion?()
                return
            }else{
                let action = SKAction.sequence([SKAction.wait(forDuration: duration), SKAction.run{self.text = String(text.prefix(index))}])
                self.run(action, completion: block)
            }
        }
        block()
    }
}

extension SKSpriteNode {
    func addGlow(radius: Float = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":radius])
    }
}
