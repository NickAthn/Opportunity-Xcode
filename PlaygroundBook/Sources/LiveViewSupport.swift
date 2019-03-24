//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Provides supporting functions for setting up a live view.
//

import UIKit
import PlaygroundSupport

public func instantiateLiveView(name: String) -> PlaygroundLiveViewable {
    let storyBoardName = name
    
    let storyboard = UIStoryboard(name: storyBoardName, bundle: nil)
    
    guard let viewController = storyboard.instantiateInitialViewController() else {
        fatalError("\(storyBoardName).storyboard does not have an initial scene; please set one or update this function")
    }
    
    guard let liveViewController = viewController as? LiveViewController else {
        fatalError("\(storyBoardName).storyboard's initial scene is not a LiveViewController; please either update the storyboard or this function")
    }
    
    return liveViewController
}

// WWDC 2018 S413 CODE

public protocol PlaygroundValueConvertible {
    func asPlaygroundValue() -> PlaygroundValue
}

// For custom values which implements the PlaygroundValueConvertible protocol
public func sendValue(_ value: PlaygroundValueConvertible) {
    let page = PlaygroundPage.current
    let proxy = page.liveView as! PlaygroundRemoteLiveViewProxy
    proxy.send(value.asPlaygroundValue())
}

// For simple PlaygroundValue supported values
public func sendValue(_ value: PlaygroundValue) {
    let page = PlaygroundPage.current
    let proxy = page.liveView as! PlaygroundRemoteLiveViewProxy
    proxy.send(value)
}
