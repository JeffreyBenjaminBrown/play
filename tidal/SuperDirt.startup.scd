s.boot();
// THIS REALLY HAS TO BE THREE PIECES
// I don't know why but I got in a lot of trouble trying to group them for faster loading.

(
/*
This is an example startup file. You can load it from your startup file
(to be found in Platform.userAppSupportDir +/+ "startup.scd")
*/
// configure the sound server: here you could add hardware specific options
// see http://doc.sccode.org/Classes/ServerOptions.html
s.options.numBuffers = 1024 * 16; // increase this if you need to load more samples
s.options.memSize = 8192 * 16; // increase this if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
// boot the server and start SuperDirt
s.waitForBoot {
	~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
	~dirt.loadSoundFiles;   // load samples (path can be passed in)
	s.sync; // wait for samples to be read
	~dirt.start(57120, [0, 0]);   // start listening on port 57120, create two busses each sending audio to channel 0
	// optional, needed for the sclang tests only:
	(
		~d1 = ~dirt.orbits[0]; // one orbit
		~d2 = ~dirt.orbits[1];
	);
};
s.latency = 0.3; // increase this if you get "late" messages
);

(
(SynthDef(\sy,	{
	|out, pan, amp = 1, qf=440, begin = 0, end = 1,
	qfa = 0, qff = 1, qpa = 0, qpf = 1|
	var env, aMod, pMod, fMod, carrier;
	env = EnvGen.ar(Env.perc(begin,end), doneAction:2) * amp;
	fMod = LFSaw.ar(qf * qff, 0, qf*qfa); // freq mod, BIG num
	pMod = LFSaw.ar(qf * qpf, 0, qpa); // phase mod
	carrier = SinOsc.ar(qf+fMod,pMod); //wks: qf+fMod
	OffsetOut.ar(out,
		DirtPan.ar(carrier,
			~dirt.numChannels, pan, env));
}).add;);

(SynthDef(\sya,	{
	|out, pan, amp = 1, qf=440, begin = 0, end = 1,
	qfa = 0, qff = 1, qpa = 0, qpf = 1, qaf = 1|
	var env, aMod, pMod, fMod, carrier;
	env = EnvGen.ar(Env.perc(begin,end), doneAction:2) * amp;
	fMod = LFSaw.ar(qf * qff, 0, qf*qfa); // freq mod, BIG num
	pMod = LFSaw.ar(qf * qpf, 0, qpa); // phase mods
	aMod = Pulse.ar(qf * qaf); // amp mod, bandlimited(not LF)
	carrier = SinOsc.ar(qf+fMod,pMod); //wks: qf+fMod
	OffsetOut.ar(out,
		DirtPan.ar(carrier*aMod,
			~dirt.numChannels, pan, env));
}).add;)
)