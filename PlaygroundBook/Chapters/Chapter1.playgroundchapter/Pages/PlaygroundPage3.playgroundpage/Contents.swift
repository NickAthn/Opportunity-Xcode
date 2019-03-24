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


func pingOppy() {
    let ping = "ping"
    do {
        try sendValue(.data(try NSKeyedArchiver.archivedData(withRootObject: ping, requiringSecureCoding: true)))
    } catch {}
}



// Completion of user-entered code:
//Use //#-code-completion syntax to allow only specified code to be entered by the user. (info here: https://developer.apple.com/documentation/swift_playgrounds/customizing_the_completions_in_the_shortcut_bar)


//#-end-hidden-code
/*:
 # The End

“Oppy, Oppy”

Our beloved little [Oppy](glossary://Opportunity) was the rover that hit a world record. She was created to last 90 days but that wasnt the case. Oppy was hungry to live and explore and she did everything in her power to stay alive.

She stayed operational for 15 years and travelled more than 45km(28miles)! Thats 60 times more than what she was created for.

Sadly, every story has to come to an end, as does this one. Opportunity sent her last signal on June 10, when a heavy dust storm hit [Mars](glossary://Mars). She went to sleep hoping she will wait out the storm.

She never woke up again…

Some say she was damaged by the storm. Others believe she is covered in dust, unable to wake up, waiting for us to come and get her.
 
***What does this story teaches us?***

Never let anybody define you. Keep fighting for what you want. **You define yourself, you find your purpose.**
 
*/
pingOppy()


