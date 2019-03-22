//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//
//Messaging from Page to Live View:
import Foundation
func showMars() -> Void {
    let mars = "showMars"
    do{
        try sendValue(.data(try NSKeyedArchiver.archivedData(withRootObject: mars, requiringSecureCoding: true)))
    } catch {}
}
func showStars() -> Void {
    let mars = "showStars"
    do{
        try sendValue(.data(try NSKeyedArchiver.archivedData(withRootObject: mars, requiringSecureCoding: true)))
    } catch  {
        
    }
}

//#-end-hidden-code
/*:
Once upon a time there was a small little rover named [Opportunity](glossary://Opportunity). The rover was the child of a very special Agency called [NASA](glossary://NASA).

At the time NASA like many other space agencies were eager to explore a planet known as [Mars](glossary://Mars) and unravel all of its secrets. The brilliant team of NASA created two twin rovers “[Opportunity](glossary://Opportunity)” and “[Spirit](glossary://Spirit)” with the goal to aid that mission and be sent far away from our earth to explore Mars.

The mission was planned to last about 90 days…

[Next Page](@next)
*/
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, showMars(), showOpportunity(), showStars())

