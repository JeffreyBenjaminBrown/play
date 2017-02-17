(
(SynthDef(\sy,	{ // by default, sine wav
	|out, pan, amp = 1, qf=440, begin = 0, end = 1,
	qfa = 0, qff = 1, qpa = 0, qpf = 1|
	var env, aMod, pMod, fMod, carrier;
	env = EnvGen.ar(Env.perc(begin,end), doneAction:2) * amp;
	fMod = LFSaw.ar(qf * qff, 0, qf*qfa); // freq mod, BIG num
	pMod = LFSaw.ar(qf * qpf, 0, qpa); // phase mod
	carrier = SinOsc.ar(qf+fMod,pMod); //wks: qf+fMod
	OffsetOut.ar(out,
		DirtPan.ar(amp*carrier, // IS IT GOOD? Then copy to other synth.
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