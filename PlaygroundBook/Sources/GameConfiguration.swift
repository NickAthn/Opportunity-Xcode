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
        static let gameInterface = "HelveticaNeue-Bold"
        static let terminalInterface = "Courier"
        static let messageInterface = "HelveticaNeue-Bold"
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
        static let year: [Int : String]! = [
            2004 : "You just landed on the Eagle crater of Mars",
            2005 : "You found a meteorite! It's name? Heat Shield Rock.",
            2007 : "NEW FIRMWARE! Both you and your brother Spirit just got updated!",
            2008 : "Dust Storm Incoming. Sadly we will have to enter into radio silence to save energy. Good luck Rovers.",
            2010 : "Spirit is not answering.",
            2011 : "Oppy, sadly your brother is lost....you are now alone.",
            2012 : "Good News. We a sent a new rover to your way named Curiosity. Say hey!",
            2014 : "Op#F#$R HE#R DSodyma#R $....MEMORY MALFUNCTION!",
            2015 : "Happy 13 years anniversary!",
            2018 : "Dust Storm Incoming."
        ]
    }
    
    public struct Endings {
        static let won = "The Sand Storm covered Opportunity's solar panels. She enters into hibernation mode to save energy."
        static let crashed = "You sir just drove Oppy straight into a giant rock."
        static let noEnergy = "It seems that your are unfamiliar with charging. Opportunity shutdown. Energy levels low."
    }
    
}
