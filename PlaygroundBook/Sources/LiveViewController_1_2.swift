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

public class LiveViewController_1_2: LiveViewController {
   // let gameScene = GameScene(fileNamed: "GameScene")

    public override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "mars")!)
//        let screenWidth = UIScreen.main.bounds.width
//        let screenHeight = UIScreen.main.bounds.height
        
        //PlaygroundPage.current.liveView.
//        1050 1472
        let scene = GameScene(size: CGSize(width: 1050, height: 1472))
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
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
        //        Uncomment the following to be able to receive messages from the Contents.swift playground page. You will need to define the type of your incoming object and then perform any actions with it.
        //
        //        guard case .data(let messageData) = message else { return }
        //        do { if let incomingObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? /*TypeOfYourObject*/ {
        //
        //                //do something with the incoming object from the playground page here
        //
        //            }
        //        } catch let error { fatalError("\(error) Unable to receive the message from the Playground page") }
        
    }
}

