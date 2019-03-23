//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//


//Messaging from Page to Live View:
import Foundation
//Use the call below to send a message with an object to the LiveView of this page. Import Foundation is required.
//sendValue(.data(try NSKeyedArchiver.archivedData(withRootObject: /*YourObject*/, requiringSecureCoding: true)))

//enum Boolean {
//    case `true`
//    case `false`
//}


//Give hints and final solution:
//PlaygroundPage.current.assessmentStatus = .fail(
//hints: [
//"You could [...].",
//"Try also [...]."
//],
//solution:
//"Do [...]."
//)


// Completion of user-entered code:
//Use //#-code-completion syntax to allow only specified code to be entered by the user. (info here: https://developer.apple.com/documentation/swift_playgrounds/customizing_the_completions_in_the_shortcut_bar)

func activateOpportunity() {
    let message = "startGame"
    do{try sendValue(.data(try NSKeyedArchiver.archivedData(withRootObject: message, requiringSecureCoding: false)))} catch {}
}
var isAccesible = false
//#-end-hidden-code
/*:
 ### The Mission

 Opportunity also known as “Oppy” was launched into the space on July, 2003 and began its big 5 month and 18 days journay.
 
 At January, 2004 Oppy touched the surface of Mars in the Eagle crater and for the first time she opened her eyes.
 
 Now its your turn to take control of Oppy and finish the story….
 
 >If you have any visual impairments change the value below to true to enable accesibility mode. With accesibility mode all entities will have a big indication in the middles making the identification easier. (R = Rock) (E = Energy)
 */
//#-code-completion(everything, hide)
//#-code-completion(literal, show, true)
isAccesible = /*#-editable-code*/false/*#-end-editable-code*/
/*:
 **Before you start** here are some information about your mission.
 **Your Objectives:**
 - Survive
 - Collect as many minerals and soil samples as roverly possible.
 - Avoid hiting rocks.
 - Don't let your energy drop below 0. Try catching the following Sun Orbs.
 
 - Sun Orb:
    ![sunOrb](sunOrb.png)
 
 **Activate Her!** [Skip to the end](@next)
*/
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, activateOpportunity())
/*#-editable-code Tap to enter code*//*#-end-editable-code*/
