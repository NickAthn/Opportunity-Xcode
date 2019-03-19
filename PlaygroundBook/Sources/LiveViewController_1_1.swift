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

public class LiveViewController_1_1: LiveViewController {
    let scnStarScene = SCNScene(named: "art.scnassets/StartParticleScene.scn")!
    let scnMarsScene = SCNScene(named: "art.scnassets/MarsScene.scn")!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let scnView = self.view as! SCNView
        scnView.scene = scnStarScene
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        showMars()
//        var geometry:SCNGeometry
//        geometry = SCNCylinder(radius: 0.3, height: 2.5)
//
//        let color = UIColor.red
//        geometry.materials.first?.diffuse.contents = color
//        let geometryNode = SCNNode(geometry: geometry)
//        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)

//        let trailEmitter = createTrail(color: color, geometry: gemomrty)
//        geometryNode.addParticleSystem(trailEmitter)
        
//        let exp = SCNParticleSystem(named: "Particles.scnp", inDirectory: nil)!
//        exp.loops = true
//
//        var particleEmitterNode = SCNNode()
//        particleEmitterNode.position = SCNVector3(0, 0, 0)
//
//        scnScene.rootNode.addChildNode(particleEmitterNode)
//        particleEmitterNode.addParticleSystem(exp)
        //scnScene.addParticleSystem(exp, transform: SCNMatrix4MakeRotation(0, 0, 0, 0))
        
        //scnScene.rootNode.addChildNode(exp)

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
    
    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        // 2
        let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        // 3
        trail.particleColor = color
        // 4
        trail.emitterShape = geometry
        // 5
        return trail
    }
    
    func showMars(){
        let scnView = self.view as! SCNView
        let mars = scnMarsScene.rootNode.childNode(withName: "planet", recursively: true)!
        scnView.scene = scnMarsScene
        
        // animate the 3d object
        //mars.runAction(SCNAction.fadeIn(duration: 5)) {
            mars.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: 10)))
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


     override public func receive(_ message: PlaygroundValue) {
//        Uncomment the following to be able to receive messages from the Contents.swift playground page. You will need to define the type of your incoming object and then perform any actions with it.
        guard case .data(let messageData) = message else { return }
        do {
            if let incomingObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? String {
                if incomingObject == "showMars" {
                    showMars()
                } else if incomingObject == "showStars"{
                    showStars()
                }
            }
        } catch let error { fatalError("\(error) Unable to receive the message from the Playground page") }
        
    }
}
