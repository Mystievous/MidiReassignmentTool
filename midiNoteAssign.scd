(
~settingsPath = thisProcess.nowExecutingPath.dirname +/+ "/settings.txt";

~settings = CSVFileReader.read(~settingsPath, true, true);

~chPath = Array.fill(16, {arg i; thisProcess.nowExecutingPath.dirname +/+ "/assignments/channel" ++ i ++ ".csv"});
// ~chPath.do({arg i; i.postln});

~channels = Array.fill(16, {arg i; CSVFileReader.read(~chPath[i], true, true)});
// ~channels.do({arg i; i.postln});

MIDIClient.init;
MIDIClient.sources;
MIDIClient.destinations;

// DIMENSIONS OF GUI
if ((Window.availableBounds.width<=390)&&(Window.availableBounds.height<=150), {
	~dimensionX = Window.availableBounds.width;
	~dimensionY = Window.availableBounds.height;
}, {
	~dimensionX = 390;
	~dimensionY = 150;
});

// SCALE FACTOR TO SCALE GUI (created at 690x500) TO AVAILABLE SCREEN AREA
~scaleX = ~dimensionX/390;
~scaleY = ~dimensionY/150;

// CREATE WINDOW
Window.closeAll;
w = Window.new("MIDIConfig", Rect.new(0,0,~dimensionX,~dimensionY))
.front
.alwaysOnTop_(true);

// CREATE ARRAY OF MIDI SOURCES
~sources = Array.fill(MIDIClient.sources.size+1,{
	arg n;
	if (n==0,
		{"";},
		{(MIDIClient.sources[n-1].device ++ "," ++ MIDIClient.sources[n-1].name);}
	);
});

// CREATE ARRAY OF MIDI DESTINATIONS
~destinations = Array.fill(MIDIClient.destinations.size+1, {
	arg n;
	if (n==0,
		{"";},
		{(MIDIClient.destinations[n-1].device ++ "," ++ MIDIClient.destinations[n-1].name);}
	);
});

~inMatch = 0;
~outMatch = 0;

// FIND IF THE SOURCE IN THE STORED SETTINGS IS CONNECTED TO THE DEVICE
(MIDIClient.sources.size+1).do({
	arg n;
	if (~inMatch==0,{
		if (n<(MIDIClient.sources.size),{
			if (MIDIClient.sources.size!=0,{
				if (MIDIClient.sources.at(n).device == ~settings.at(0).at(1),{
					if (MIDIClient.sources.at(n).name == ~settings.at(0).at(2),{
						~inValue = n+1;
						~inMatch = 1;
					});
				});
			},
			{
				~inValue = 0;
				~inMatch = 1;
			});
		},
		{
			~inValue = 0;
			~inMatch = 0;
		});
	});
});

// FIND IF THE DESTINATION IN THE STORED SETTINGS IS CONNECTED TO THE DEVICE
(MIDIClient.destinations.size+1).do({
	arg n;
	if (~outMatch==0,{
		if (n<(MIDIClient.destinations.size),{
			if (MIDIClient.destinations.size!=0,{
				if (MIDIClient.destinations.at(n).device == ~settings.at(1).at(1),{
					if (MIDIClient.destinations.at(n).name == ~settings.at(1).at(2),{
						~outValue = n+1;
						~outMatch = 1;
					});
				});
			},
			{
				~outValue = 0;
				~outMatch = 1;
			});
		},
		{
			~outValue = 0;
			~outMatch = 0;
		});
	});
});

//CONNECT MIDI DEVICES ACCORDING TO ~settingsPath FILE
~connected = 0;

if (~inMatch!=0, {MIDIIn.connect(0, ~inValue-1); ~connected = 1;});
if(~outMatch!=0, {m = MIDIOut.newByName(~settings.at(1).at(1), ~settings.at(1).at(2), true); m.latency = 0; Platform.case(
	\linux,        { m.connect(2) }
);});

StaticText(w, Rect(~scaleX*230,~scaleY*15,~scaleX*120,~scaleY*27))
.string_("Input MIDI Device:");

//CREATE DROP DOWN MENUS FOR CONNECTED MIDI DEVICES
~selectIn = PopUpMenu(w, Rect(~scaleX*230,~scaleY*37,~scaleX*120,~scaleY*27))
.items_(~sources)
.value_(~inValue)
.action_({
	if (~connected==1, {
		MIDIIn.disconnect(0,~inValue-1);
		~connected=0;
	});
	~inValue = ~selectIn.value;
	f = File(~settingsPath,"w");
	(f.write("in"); f.write(","); f.write(~sources[~inValue]); f.write("\n"););
	(f.write("out"); f.write(","); f.write(~destinations[~outValue]); f.write("\n"););
	f.close;
	~settings = CSVFileReader.read(~settingsPath, true, true);
	if (~inValue!=0, {MIDIIn.connect(0,~inValue-1); ~connected = 1;});
}
);

StaticText(w, Rect(~scaleX*230,~scaleY*70,~scaleX*120,~scaleY*27))
.string_("Output MIDI Device:");

~selectOut = PopUpMenu(w, Rect(~scaleX*230,~scaleY*92,~scaleX*120,~scaleY*27))
.items_(~destinations)
.value_(~outValue)
.action_({
	~outValue = ~selectOut.value;
	f = File(~settingsPath,"w");
	(f.write("in"); f.write(","); f.write(~sources[~inValue]); f.write("\n"););
	(f.write("out"); f.write(","); f.write(~destinations[~outValue]); f.write("\n"););
	f.close;
	~settings = CSVFileReader.read(~settingsPath, true, true);
	if(~outValue!=0, {m = MIDIOut.newByName(~settings.at(1).at(1), ~settings.at(1).at(2), true); m.latency = 0; Platform.case(
		\linux,        { m.connect(2) }
	);});
});

~selectedNote = [0, 60];

StaticText(w, Rect(~scaleX*116,~scaleY*3,~scaleX*50,~scaleY*22))
.string_("Channel:");

~selectInChannel = PopUpMenu(w, Rect(~scaleX*114.5,~scaleY*25,~scaleX*50,~scaleY*22))
.items_(Array.fill(16, {arg i; i+1});)
.value_(0)
.allowsReselection_(true)
.action_({
	~selectedNote.put(0, ~selectInChannel.value);
	~selectOutChannel.value_(~channels.at(~selectInChannel.value).at(~selectInNote.value).at(0));
	~selectOutNote.value_(~channels.at(~selectInChannel.value).at(~selectInNote.value).at(1));
	// ("Channel: " ++ ~selectedNote[0]).postln;
});

StaticText(w, Rect(~scaleX*173,~scaleY*3,~scaleX*50,~scaleY*22))
.string_("Note:");

~selectInNote = PopUpMenu(w, Rect(~scaleX*170.5,~scaleY*25,~scaleX*50,~scaleY*22))
.items_(Array.fill(128, {arg i; i});)
.value_(60)
.allowsReselection_(true)
.action_({
	~selectedNote.put(1, ~selectInNote.value);
	~selectOutChannel.value_(~channels.at(~selectInChannel.value).at(~selectInNote.value).at(0));
	~selectOutNote.value_(~channels.at(~selectInChannel.value).at(~selectInNote.value).at(1));
	// ~selectedNote.postln;
});

~selectOutChannel = PopUpMenu(w, Rect(~scaleX*114.5,~scaleY*64,~scaleX*50,~scaleY*22))
.items_(Array.fill(16, {arg i; i+1});)
.value_(~channels.at(0).at(60).at(0));

~selectOutNote = PopUpMenu(w, Rect(~scaleX*170.5,~scaleY*64,~scaleX*50,~scaleY*22))
.items_(Array.fill(128, {arg i; i});)
.value_(~channels.at(0).at(60).at(1));

~applyChange = Button(w, Rect(~scaleX*122.5,~scaleY*103,~scaleX*90,~scaleY*22))
.states_([["Apply Changes",Color.black,Color.white]])
.action_({

	~channels.at(~selectedNote[0]).at(~selectedNote[1]).put(1, ~selectOutNote.value);

	~channels.at(~selectedNote[0]).at(~selectedNote[1]).put(0, ~selectOutChannel.value);

	~channels.at(~selectedNote[0]).at(~selectedNote[1]).postln;

	f = File(~chPath[~selectedNote[0]],"w");
	(0..127).do{arg i; f.write(~channels.at(~selectedNote[0]).at(i).at(0).asString); f.write(","); f.write(~channels.at(~selectedNote[0]).at(i).at(1).asString); f.write("\n");};
	f.close;
});

//CREATE BUTTONS FOR MANIPULATING CALIBRATION
~detectArm = Button.new(w, Rect(~scaleX*20,~scaleY*25,~scaleX*65,~scaleY*22))
.states_([["Detect Note",Color.black,Color.white],["Detect Note",Color.white,"#780c0c"]]);

StaticText(w, Rect(~scaleX*95,~scaleY*24,~scaleX*22,~scaleY*22))
.string_("In:");

StaticText(w, Rect(~scaleX*90,~scaleY*63,~scaleX*22,~scaleY*22))
.string_("Out:");

/*~maxArm = Button.new(w, Rect(~scaleX*150,~scaleY*190,~scaleX*90,~scaleY*30))
.states_([["Max Disarmed",Color.black,Color.white],["Max Armed",Color.white,Color.red]]);*/

~detectState=0;
// ~maxState=0;

~detectArm.action_({
	// ~maxArm.value_(0);
	~detectState = ~detectArm.value;
	// ~maxState = 0;
});

/*~maxArm.action_({
	~minArm.value_(0);
	~maxState = ~maxArm.value;
	~minState = 0;
});*/

//pass note on messages
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;

	m.noteOn(~channels.at(chan).at(nn).at(0), ~channels.at(chan).at(nn).at(1), vel);

	if (~detectState==1, {
		~selectedNote = [chan, nn];
		defer {~selectInChannel.valueAction_(~selectedNote.at(0));};
		defer {~selectInNote.valueAction_(~selectedNote.at(1));};
		// defer {~selectedNote.postln};
		defer {~detectArm.valueAction_(0);};
	});
	// [vel, nn, chan].postln;
	[~channels.at(chan).at(nn).at(0), ~channels.at(chan).at(nn).at(1), vel].postln;
});

//pass note off messages
MIDIdef.noteOff(\noteOffTest, {
	arg vel, nn, chan, src;
	("note off").postln;
	m.noteOff(~channels.at(chan).at(nn).at(0), ~channels.at(chan).at(nn).at(1));

});

//pass control messages
MIDIdef.cc(\controlTest, {
	arg chan, cn, val;
	if (cn != 7, {
		m.control(chan, cn, val);
		[chan, cn, val].postln;
	});
});

//pass bend messages
MIDIdef.bend(\bendTest, {
	arg chan, val;
	m.bend(chan, val);
	[chan, val].postln;

});

//pass polytouch messages
MIDIdef.polytouch(\polyTest, {
	arg chan, nn, val;
	m.polyTouch(~channels.at(chan).at(nn).at(0), ~channels.at(chan).at(nn).at(1), val);
	[chan, nn, val].postln;
});

//pass touch messages
MIDIdef.touch(\touchTest, {
	arg chan, val;
	m.touch(chan, val);
	[chan, val].postln;
});

//pass program change messages
MIDIdef.program(\progTest, {
	arg pn, chan;
	m.program(chan, pn);
	[chan, pn].postln;
});

//pass sysex messages
MIDIdef.sysex(\sysexTest, {
	arg packet;
	m.sysex(packet);
	[packet].postln;
});

//End of Main block
);



