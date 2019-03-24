//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Provides supporting functions for setting up a live view.
//

import UIKit
import Foundation
import PlaygroundSupport

public class TheEnd: LiveViewController {
    @IBOutlet weak var consoleTextView: UITextView!
    
//    let text = ""
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//         .setTextWithTypeAnimation(typedText: text, characterDelay:  10) //less delay is faster
        //pingOppy()
    }


    var isTyping = false
    public func pingOppy(){
        isTyping = true
        var text = """
PING Opportunity: 56 data bytes

Request Timed Out.
Request Timed Out.
Request Timed Out.
Request Timed Out.

--- Opportunity ping statistics ---
4 packets transmitted, 0 packets received, 100.0% packet loss
round-trip min/avg/max/stddev = 0/0/0/0 ms

➜  ~
"""
        consoleTextView.appendTextWithTypeAnimation(typedText: " ping Opportunity\n") {
            self.consoleTextView.appendTextWithTypeAnimation(typedText: text, characterDelay: 0.5) {
                self.isTyping = false
                let bottom = NSMakeRange(self.consoleTextView.text.count - 1, 1)
                self.consoleTextView.scrollRangeToVisible(bottom)
            }
        }
}
    
    override public func receive(_ message: PlaygroundValue) {
        //        Uncomment the following to be able to receive messages from the Contents.swift playground page. You will need to define the type of your incoming object and then perform any actions with it.
        //
                guard case .data(let messageData) = message else { return }
                do { if let incomingObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? String {
                    if incomingObject == "ping" && isTyping == false{
                        pingOppy()
                    }
                    }
                } catch let error { fatalError("\(error) Unable to receive the message from the Playground page") }
        
    }
}

extension UITextView {
    func appendTextWithTypeAnimation(typedText: String, characterDelay: TimeInterval = 5.0, completion: @escaping () -> Void) {
        var writingTask: DispatchWorkItem?
        writingTask = DispatchWorkItem { [weak weakSelf = self] in
            for character in typedText {
                DispatchQueue.main.async {
                    weakSelf?.text!.append(character)
                }
                Thread.sleep(forTimeInterval: characterDelay/100)
                if typedText.last == character {
                    completion()
                }
            }
        }
        
        if let task = writingTask {
            let queue = DispatchQueue(label: "typespeed", qos: DispatchQoS.userInteractive)
            queue.asyncAfter(deadline: .now() + 0.05, execute: task)
        }
    }
}
