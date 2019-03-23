//
//  GameZPositions.swift
//  LiveViewTestApp
//
//  Created by Nikolaos Athanasiou on 23/03/2019.
//

import Foundation
import UIKit

public struct Game {
    public struct FontNames {
        struct helveticaNeue {
            static let bold = "HelveticaNeue-Bold"
        }
    }
    
    public struct PositionZ {
        static let topLevel: CGFloat = 20
        
        static let userInterface: CGFloat = 15
        static let userInterfaceBackground: CGFloat = 14

        static let background: CGFloat = -15
        static let backgroundSupplementary: CGFloat = -14
        
        static let actors: CGFloat = 5
        static let enviromentalChanges: CGFloat = 6
        
    }
    
    public struct Transmissions {
        
    }
    
    public struct Endings {
        static let won = "The Sand Storm covered Opportunity's solar panels. She enters into hibernation mode to save energy."
        static let crashed = "You sir just drove Oppy straight into a giant rock."
        static let noEnergy = "It seems that your are unfamiliar with charging. Opportunity shutdown. Energy levels low."
    }
    
}
