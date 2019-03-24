//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//
//Messaging from Page to Live View:
import Foundation

public enum Model {
    case mars
    case oppy
    case stars
}

func showModel(_ show: Model){
    var modelString = "showMars"
    
    if show == .mars {
        modelString = "showMars"
    } else {
        modelString = "showStars"
    }
    
    do{
        try sendValue(.data(try NSKeyedArchiver.archivedData(withRootObject: modelString, requiringSecureCoding: false)))
    } catch {}
}

//Give hints and final solution:
//#-end-hidden-code
/*:
 # The Launch
Once upon a time there was a small little rover named [Opportunity](glossary://Opportunity). The rover was the child of a very special Agency called [NASA](glossary://NASA).

At the time NASA like many other space agencies were eager to explore a planet known as [Mars](glossary://Mars) and unravel all of its secrets. The brilliant team of NASA created two twin rovers “[Opportunity](glossary://Opportunity)” and “[Spirit](glossary://Spirit)” with the goal to aid that mission and be sent far away from our earth to explore Mars.
*/
//#-code-completion(everything, hide)
//#-code-completion(everything, show, Model)
showModel(./*#-editable-code model to show*/stars/*#-end-editable-code*/)
/*:
 
 One of the primary goals of those two rovers was to study a variety of rocks and soil.
 
 **The mission on mars was planned to last 90 days….**
 
 [Next Page](@next)
 */
