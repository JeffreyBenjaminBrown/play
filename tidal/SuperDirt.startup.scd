s.boot()
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

( // sine, just-intoned
SynthDef(\si, { |out, pan, amp = 1, qf, begin = 0, end = 1|
	var env, sound;
  env = EnvGen.ar(Env.perc(begin,end), doneAction:2) * amp;
	sound = Saw.ar(qf);
	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, env)
	)
}).add;
)

( // sim, with amp mod
SynthDef(\sia, { |out, pan, amp = 1, qf, qaf = 1, begin = 0, end = 1|
	var env, modulator, sound;
  env = EnvGen.ar(Env.perc(begin,end), doneAction:2) * amp;
	modulator = SinOsc.kr(qaf, 0, 1);
	sound = Saw.ar(qf,modulator);
	OffsetOut.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, env)
	)
}).add;
)
