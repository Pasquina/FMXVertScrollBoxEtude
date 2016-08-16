# FMXVertScrollBoxEtude

A project group that explores Firemonkey scroll boxes, virtual keyboards and includes a Delphi component to ease the programming effort required to implement a vertical scroll box that avoids the problem of input fields obscured by the virtual keyboard

The Vertical Scroll Box is essential for the repositioning of a screen displayed on a mobile device when the virtual keyboard appears. The virtual keyboard often obscures the input field, making it difficult for the user to complete the input process.

I originally started by simply writing some simple code to explore Firemonkey scroll boxes. This eventually led to the problem of navigation among the various input fields that might appear on a form. Finally, I developed a component that encapsulates the code required to implement a scroll box that repositions the current input field just above the virtual keyboard to facilitate both development and ease of use. There are four projects in this project group:

ScrollDemo.exe: This is a program that allows the user to make dynamic changes to a Firemonkey scroll box and then display the results of the changes. It is particularly concerned with the way Firemonkey calculates the scroll box bounds in response to the contens of the scroll box, or as are forced by user or program input.

VKLogger.exe is a program that logs events that occur when the focus changes on a Firemonkey form. It additionally logs the virtual keyboard show and hide events along with the parameters provided to the event handlers. It demonstrates some of the anomalies of Firemonkey or Android in that the bounds of a virtual keyboard are not reliably reported; additionally, the ReturnKeyType property of TEdit fields are not reliably observed.

VyDVSBFMXScroll.bpl is a component that eases the implementation of a vertical scroll box that "slides" up to accomodate a virtual keyboard. The component must be installed to be used.

VKScrollDemo.exe is the final project that incorporates all of the information gathered by the previous projects. It demonstrates navigation techniques, the use of the VyDVSBFMXScroll component and includes a logging capability similar to VKLogger.exe that traces event execution and parameter values. The program has been successfully run on an Android 5" phone, two different Android 7" tablets and a 10" Android tablet. It also runs on a Windows machine, but this is not terribly useful. The phone is a Samsung Galaxy Note 3 Model number SM-N900P running Android 5.0. One 7" tablet is a Samsung Galaxy Tab 3 Model number SM-T217S running Android 4.4.2. The other 7" tablet is a Samsung Galaxy Tab 3 Model number SM-T310 running Android 4.4.2. The 10" tablet is a Google Nexus 10 running Android 5.1.1.

