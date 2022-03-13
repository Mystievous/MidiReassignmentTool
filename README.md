# MidiReassignmentTool
Allows midi inputs to be reassigned before being outputted to another device. 


Requires Windows and [Supercollider 3.11.2](https://supercollider.github.io/download) (Other versions of supercollider are compatible, and can be used by adjusting the batch file). 

Software like [loopMIDI](https://www.tobias-erichsen.de/software/loopmidi.html) can be used to create virtual midi ports for communication with daws and vst hosts on the same computer. 

## Instructions

1. Download the application using the green code button. 

2. run the midiNoteAssign.bat file, which will run the application using sclang.

3. Select the input and output midi devices with the respective dropdowns on the right of the menu. 

4. Use the "Detect Note" button or the Channel and Note dropdowns next to "In" to select the input note you want to be changed, and select the desired output with the "Out" dropdowns.

5. Once your change is selected click "Apply Changes" to assign the note to the new output.
