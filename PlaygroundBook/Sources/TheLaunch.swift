//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Provides supporting functions for setting up a live view.
//

import UIKit
import Foundation
import PlaygroundSupport
import SceneKit

public class TheLaunch: LiveViewController {
    let scnStarScene = SCNScene(named: "art.scnassets/StartParticleScene.scn")!
    let scnMarsScene = SCNScene(named: "art.scnassets/MarsScene.scn")!
    let scnOppyScene = SCNScene(named: "art.scnassets/Mer/MER.scn")!

    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let scnView = self.view as! SCNView
        scnView.scene = scnStarScene
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
    }
    
    override public var shouldAutorotate: Bool {
        return true
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    func showMars(){
        let scnView = self.view as! SCNView
        let mars = scnMarsScene.rootNode.childNode(withName: "planet", recursively: true)!
        scnMarsScene.rootNode.childNode(withName: "planet", recursively: true)!.isHidden = false
        scnView.scene = scnMarsScene
        // animate the 3d object
        //mars.runAction(SCNAction.fadeIn(duration: 5)) {
            mars.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 10)))
        //}
        
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        if #available(iOS 11.0, *) {
            scnView.cameraControlConfiguration.allowsTranslation = false
        } else {
            // Fallback on earlier versions
        }
        scnView.antialiasingMode = .multisampling4X
    }
    func showStars(){
        let scnView = self.view as! SCNView
        scnView.scene = scnStarScene
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
    }
    func showOppy(){
        let scnView = self.view as! SCNView
        let oppy = scnOppyScene.rootNode.childNode(withName: "body", recursively: true)!
        scnOppyScene.rootNode.childNode(withName: "body", recursively: true)!.isHidden = false
        scnView.scene = scnOppyScene
        // animate the 3d object
        //mars.runAction(SCNAction.fadeIn(duration: 5)) {
        oppy.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 10)))
        //}
        
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        if #available(iOS 11.0, *) {
            scnView.cameraControlConfiguration.allowsTranslation = false
        } else {
            // Fallback on earlier versions
        }
        scnView.antialiasingMode = .multisampling4X

    }


     override public func receive(_ message: PlaygroundValue) {
        guard case .data(let messageData) = message else { return }
        do {
            if let incomingObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? String {
                if incomingObject == "showMars" {
                    showMars()
                } else if incomingObject == "showStars"{
                    showStars()
                } else if incomingObject == "showOppy"{
                    showOppy()
                }
            }
        } catch let error { fatalError("\(error) Unable to receive the message from the Playground page") }
        
    }
}
