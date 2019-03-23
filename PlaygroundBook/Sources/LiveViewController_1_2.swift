//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Provides supporting functions for setting up a live view.
//

import UIKit
import SpriteKit
import GameplayKit
import PlaygroundSupport

public class LiveViewController_1_2: LiveViewController, GameViewController{
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!

   // let gameScene = GameScene(fileNamed: "GameScene")
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator){
        
        super.viewWillTransition(to: size, with: coordinator)
        
        guard
            let skView = self.view as? SKView,
            let canReceiveRotationEvents = skView.scene as? CanReceiveTransitionEvents else { return }
        
        canReceiveRotationEvents.viewWillTransition(to: size)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        if view.frame.width > view.frame.height { // Landscape
            screenWidth = view.frame.width/2
            screenHeight = view.frame.height
        } else { // Portrait
            screenWidth = view.frame.height/2
            screenHeight = view.frame.width
        }

        let scene = StartGameScene(size: CGSize(width: screenWidth, height: screenHeight), viewController: self)
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        //let gameView = SKView(frame: CGRect(x: 0, y: 0, width: 1050, height: 1472))
    }
    
    public func startGame() {
        let scene = GameScene(size: CGSize(width: screenWidth*2, height: screenHeight*2))
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFit
        skView.presentScene(scene, transition: SKTransition.doorsOpenVertical(withDuration: 3))
    }
    func connect() {
        let skView = view as! SKView
        let currentScene = skView.scene as? StartGameScene
        currentScene?.connect()
    }
    override public var shouldAutorotate: Bool {
        return true
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override public func receive(_ message: PlaygroundValue) {
        guard case .data(let messageData) = message else { return }
        do { if let incomingObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? String {
            if incomingObject == "startGame" {
                connect()
            }
            
            }
        } catch let error { fatalError("\(error) Unable to receive the message from the Playground page") }
    }
}

