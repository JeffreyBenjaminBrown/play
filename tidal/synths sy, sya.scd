(
s.options.numBuffers = 1024 * 64;
SuperDirt.start;

(SynthDef(\sy,	{ // by default, sine wav
	|out, pan, amp = 1, qf=440, begin = 0, end = 1,
	qfa = 0, qff = 1, qpa = 0, qpf = 1, qaa = 0, qaf = 1|
	var env, aMod, pMod, fMod, carrier;
	env = EnvGen.ar(Env.perc(begin,end), doneAction:2) * amp;
	fMod = LFSaw.ar(qf * qff, 0, qf*qfa); // freq mod, BIG num
	pMod = LFSaw.ar(qf * qpf, 0, qpa); // phase mod
	aMod = 1+(qaa*Pulse.ar(qf * qaf,0.5,2,-1)); // amp mod, bandlimited(not LF)
	  // if qaa = 0, this has no effect
	carrier = SinOsc.ar(qf+fMod,pMod); //wks: qf+fMod
	OffsetOut.ar(out,
		DirtPan.ar(1*carrier*aMod, // add carrier!
			~dirt.numChannels, pan, env));
}).add;);

(SynthDef(\sya,	{
	|out, pan, amp = 1, qf=440, begin = 0, end = 1,
	qfa = 0, qff = 1, qpa = 0, qpf = 1, qaf = 1, qaa = 1|
	var env, aMod, pMod, fMod, carrier;
	env = EnvGen.ar(Env.perc(begin,end), doneAction:2) * amp;
	fMod = LFSaw.ar(qf * qff, 0, qf*qfa); // freq mod, BIG num
	pMod = LFSaw.ar(qf * qpf, 0, qpa); // phase mods
	aMod = Pulse.ar(qf * qaf,0.5,qaa); // amp mod, bandlimited(not LF)
	carrier = SinOsc.ar(qf+fMod,pMod); //wks: qf+fMod
	OffsetOut.ar(out,
		DirtPan.ar(carrier*aMod,
			~dirt.numChannels, pan, env));
}).add;)
)