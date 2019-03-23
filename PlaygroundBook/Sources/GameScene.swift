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

public enum GameState {
    case ending
    case active
    case freezed
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
    // Rover and its Properties
    var rover = SKSpriteNode()
    var isHit = false
    
    var canMove = false
    var centerPoint : CGFloat!
    
    var state: GameState = .freezed
    
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
    
    let gameTime = 120
    var gameSpeed: CGFloat = 15
    var maxTime = 0.8
    var minTime = 0.3
    public func startGame(){
        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.startCountDown), userInfo: nil, repeats: true)
        addChild(backgroundSound)
        backgroundSound.autoplayLooped = true
    }
    
    
    override public func didMove(to view: SKView) {
        background.zPosition = Game.PositionZ.background
        background.position = CGPoint(x: 0, y: 0 )
        background.yScale = 2
        background.xScale = 2
        
        addChild(background)
        
        let changeVolume = SKAction.changeVolume(to: 0.3, duration: 0)
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
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.loseEnergy), userInfo: nil, repeats: true)

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
            }
            let touchLocation = touch.location(in: self)
            moveRover(to: touchLocation)
        }
        canMove = true
    }
    
    
    func moveRover(to location: CGPoint){
        let distance =  abs((Double(location.x - rover.position.x)))
        let distanceY = abs((Double(location.y - rover.position.y)))
        let speed: Double = 900
        if location.x > (self.size.width)/2 || location.x < -((self.size.width)/2) {
        } else {
            let move = SKAction.moveTo(x: location.x, duration: distance/speed)
            let moveUp = SKAction.moveTo(y: location.y, duration: distanceY/speed)
            
//             Move Player with steady speed of "speed" points
            if location.x - rover.position.x > 0 {
                rover.run(SKAction.rotate(toAngle: -0.5, duration: 0.5))
            } else {
                rover.run(SKAction.rotate(toAngle: 0.5, duration: 0.5))
            }
            rover.run(move) {
                self.rover.run(SKAction.rotate(toAngle: 0, duration: 0.5), withKey: "still")
            }
            rover.run(moveUp)
        }
    }
    
    
    // TODO: EVIL DOING MUST CHAGNE
    var didFinish = false
    override public func update(_ currentTime: TimeInterval) {
        if year == 2018 && energy > 0 && didFinish == false{
            endGame(state: End.won)
            didFinish = true
        } else if energy == 0  && didFinish == false {
            didFinish = true
            endGame(state: End.noEnergy)
        }
        throwProjectiles()
    }
    
    func transmissionManager() {
        switch year {
        case 2004: addIncomingTransmission(text: Game.Transmissions.year[2004]!)
        case 2005: addIncomingTransmission(text: Game.Transmissions.year[2005]!)
        case 2007: addIncomingTransmission(text: Game.Transmissions.year[2007]!)
        case 2008: addIncomingTransmission(text: Game.Transmissions.year[2008]!)
        case 2010: addIncomingTransmission(text: Game.Transmissions.year[2010]!)
        case 2011: addIncomingTransmission(text: Game.Transmissions.year[2011]!)
        case 2012: addIncomingTransmission(text: Game.Transmissions.year[2012]!)
        case 2014: addIncomingTransmission(text: Game.Transmissions.year[2014]!)
        case 2015: addIncomingTransmission(text: Game.Transmissions.year[2015]!)
        case 2018: addIncomingTransmission(text: Game.Transmissions.year[2018]!)
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
        rover.xScale = 0.70
        rover.yScale = 0.70
        rover.name = "rover"
        rover.zPosition = Game.PositionZ.actors
        rover.position.x = 0
        rover.position.y = self.frame.minY + rover.size.height + 30
        
        let offsetX: CGFloat = rover.frame.size.width * rover.anchorPoint.x
        let offsetY: CGFloat = rover.frame.size.height * rover.anchorPoint.y
        
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: 77 - offsetX, y: 120 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 92 - offsetX, y: 120 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 129 - offsetX, y: 118 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 134 - offsetX, y: 115 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 151 - offsetX, y: 87 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 171 - offsetX, y: 53 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 173 - offsetX, y: 47 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 170 - offsetX, y: 40 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 158 - offsetX, y: 16 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 106 - offsetX, y: 1 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 67 - offsetX, y: 1 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 15 - offsetX, y: 16 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 5 - offsetX, y: 34 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 0 - offsetX, y: 47 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 2 - offsetX, y: 53 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 22 - offsetX, y: 87 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 39 - offsetX, y: 116 - offsetY), transform: .identity)
        path.addLine(to: CGPoint(x: 50 - offsetX, y: 120 - offsetY), transform: .identity)

        path.closeSubpath()
        
        rover.physicsBody = SKPhysicsBody(polygonFrom: path)

//        rover.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: rover.size.width, height: rover.size.height))
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
                state = .active
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
        if state != .freezed {
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
    func addEnergy(){
        if energy + 8 > 100 {
            energy = 100
        } else {
            energy += 8
        }
    }
    
    func loseEnergyWith(amount: Int){
        if state != .freezed{
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
        if state == .freezed{
            let valueToDecrease = (100/(gameTime)) // GameTime/ THe amout of time the user will finish his power
            if energy - valueToDecrease < 0 || energy == 0{ // END GAME
                energy = 0
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
    
    @objc func incrementYear(){
        if state == .active{
            year += 1
            if year == 2008 {addSandstorm(for: 10)}
            scoreLabel.text = String(year)
            transmissionManager()
            difficulty()
        }
    }
    
    func addSandstorm(for time: TimeInterval = 10){
        let sandStorm = SKEmitterNode(fileNamed: "SandStorm")!

        sandStorm.zPosition = Game.PositionZ.enviromentalChanges
        sandStorm.position = CGPoint(x: 0, y: (view?.frame.maxY ?? 0) + 60)
        sandStorm.particlePositionRange = CGVector(dx:((view?.frame.width)!)*2, dy: 0)
//        sandStorm.emissionAngle = 0
        addChild(sandStorm)

        let wait = SKAction.wait(forDuration: time)
        let fadeOut = SKAction.fadeOut(withDuration: 5)
        
        let soundNode = SKAudioNode(fileNamed: Sounds.storm)
        soundNode.autoplayLooped = true
        
        let setVolume = SKAction.changeVolume(to: 0, duration: 0)
        let waitSound = SKAction.wait(forDuration: time-5)
        let increaseVolume = SKAction.changeVolume(to: 1, duration: 5)
        let decreaseVolume = SKAction.changeVolume(to: 0, duration: 5)
        soundNode.run(SKAction.sequence([setVolume,increaseVolume,waitSound,decreaseVolume]))
        addChild(soundNode)
        
        sandStorm.run(SKAction.sequence([wait,fadeOut])) {
            sandStorm.removeFromParent()
            soundNode.removeFromParent()
        }
    }
    
    func difficulty() {
        if year == 2019 || year == 2012 || year == 2014 || year == 2015 || year == 2016 {
            gameSpeed += 3
            maxTime -= 2
            minTime -= 1
        }
    }
    
    func dimScreen(in time: TimeInterval){
        let dimPanel = SKSpriteNode(color: UIColor.black, size: background.size)
        dimPanel.alpha = 0
        dimPanel.zPosition = Game.PositionZ.topLevel
        dimPanel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(dimPanel)
        
        dimPanel.run(SKAction.fadeAlpha(to: 1, duration: time))

    }

    func endGame(state: End){
        self.state = .ending
        let endScene = EndGameScene(fileNamed: "EndGameScene.sks", state: state)!
        if state == .won {
            addSandstorm(for: 35)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15), execute: {
                self.dimScreen(in: 5)
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(20), execute: {
                self.view?.presentScene(endScene, transition: SKTransition.crossFade(withDuration: 1))
            })

        } else if state == .crashed {
            self.dimScreen(in: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                self.view?.presentScene(endScene, transition: SKTransition.crossFade(withDuration: 1))
            })
        } else if state == .noEnergy {
            self.dimScreen(in: 3)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                self.view?.presentScene(endScene, transition: SKTransition.crossFade(withDuration: 1))
            })

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
