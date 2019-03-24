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
var isAccessible = false
var gameTime = 120

func activateOpportunity() {
    var message = "startGame"
    if isAccessible {
        message += "A"
    }
    do{try sendValue(.data(try NSKeyedArchiver.archivedData(withRootObject: gameTime, requiringSecureCoding: false)))} catch {}
    do{try sendValue(.data(try NSKeyedArchiver.archivedData(withRootObject: message, requiringSecureCoding: false)))} catch {}
}
//#-end-hidden-code
/*:
 # The Mission

 [Opportunity](glossary://Opportunity) also known as “Oppy” was launched into space on July, 2003 and began its big 5 month and 18 days journey.
 
 On January, 2004 Oppy touched the surface of Mars in the [Eagle Crater](glossary://EagleCrater) and for the first time she opened her eyes.
 
 Now its your turn to take control of Oppy and finish the story….
 
 >If you have any visual impairments you can change the value below to 'true' to enable accessibility mode. With accesibility mode, all entities will have a big indication in the middle making the identification of them easier. (R = Rock) (E = Energy)
 */
//#-code-completion(everything, hide)
//#-code-completion(literal, show, true)
isAccessible = /*#-editable-code*/false/*#-end-editable-code*/
/*:
 > You can change the game time below for a faster experience. Recommended value is between 100 seconds - 120 seconds.
 */
gameTime = /*#-editable-code*/120/*#-end-editable-code*/
/*:
 **Before you start** here is information about your mission.
 **Your Objectives:**
 - Survive
 * Callout(Rock):
 ![rock1](rock1.png)
 - Avoid hitting rocks.
 * Callout(Energy Orb):
 ![sunOrb](sunOrb.png)
 - Don't let your energy drop below 0. Try catching as many Sun Orbs as roverly possible.

 **Activate Her!**
*/
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, activateOpportunity())
activateOpportunity()
