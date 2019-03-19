//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Provides supporting functions for setting up a live view.
//

import UIKit
import Foundation
import PlaygroundSupport

public class LiveViewController_1_3: LiveViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
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
