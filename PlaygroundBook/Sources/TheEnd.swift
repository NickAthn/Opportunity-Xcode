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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }


    var isTyping = false
    var isCalled = false
    public func pingOppy(){
        isTyping = true
        consoleTextView.appendTextWithTypeAnimation(typedText: " ping Opportunity\n") {
            if !self.isCalled {
                self.addText()
            }
        }
}
    func addText(){
        isCalled = true
        self.consoleTextView.text += "PING Opportunity: 56 data bytes\n\n"

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500) , execute: {
            self.consoleTextView.text += "Request Timed Out. \n"
            self.goToBottom()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000) , execute: {
            self.consoleTextView.text += "Request Timed Out. \n"
            self.goToBottom()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500) , execute: {
            self.consoleTextView.text += "Request Timed Out. \n"
            self.goToBottom()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000) , execute: {
            self.consoleTextView.text += "Request Timed Out. \n\n"
            self.goToBottom()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2300), execute: {
            self.consoleTextView.text += """
            --- Opportunity ping statistics ---
            4 packets transmitted, 0 packets received, 100.0% packet loss
            round-trip min/avg/max/stddev = 0/0/0/0 ms
            
            ➜  ~
            """
            self.isTyping = false
            self.isCalled = false
            self.goToBottom()
        })

    }
    
    func goToBottom(){
        let bottom = NSMakeRange(self.consoleTextView.text.count - 1, 1)
        self.consoleTextView.scrollRangeToVisible(bottom)
    }
    
    override public func receive(_ message: PlaygroundValue) {
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

