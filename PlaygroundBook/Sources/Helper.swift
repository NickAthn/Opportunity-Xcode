//
//  Helper.swift
//  spriteKit
//
//  Created by Nikolaos Athanasiou on 19/03/2019.
//  Copyright © 2019 athanasiou. All rights reserved.
//

import Foundation
import UIKit

public struct ColliderType {
    static let CAR_COLLIDER : UInt32 = 0
    
    static let ITEM_COLLIDER : UInt32 = 1
    static let ITEM_COLLIDER_1 : UInt32 = 2
}

public class Helper : NSObject {
    
    func randomBetweenTwoNumbers(firstNumber : CGFloat ,  secondNumber : CGFloat) -> CGFloat{
        return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
}

public class Settings {
    static let sharedInstance = Settings()
    
    private init(){
        
    }
    
    var highScore = 0
}


