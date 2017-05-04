(
s.options.numBuffers = 1024 * 64;
SuperDirt.start;

// warning: do not try to unify qf with the preexisting speed symbol
// speed has its own effect elsewhere, so it would serve double-duty, and the effects are unmusical

(SynthDef(\sy,	{ // by default, sine wav
	|out, pan, amp = 1, qf=440, begin = 0, end = 1,
	qfa = 0, qff = 1, qpa = 0, qpf = 1, qaa = 0, qaf = 1|
	var env, aMod, pMod, fMod, carrier;
	env = EnvGen.ar(Env.perc(begin,end), doneAction:2) * amp;
	fMod = LFSaw.ar(qf * qff, 0, qf*qfa); // freq mod (hence big amplitude)
	pMod = LFSaw.ar(qf * qpf, 0, qpa); // phase mod
	aMod = 1+(qaa*Pulse.ar(qf * qaf,0.5,2,-1)); // amp mod, bandlimited(not LF)
	  // if qaa = 0, this has no effect (unlike sya)
	carrier = SinOsc.ar(qf+fMod,pMod);
	OffsetOut.ar(out,
		DirtPan.ar(1*carrier*aMod,
			~dirt.numChannels, pan, env));
}).add;);

(SynthDef(\sya,	{
	|out, pan, amp = 1, qf=440, begin = 0, end = 1,
	qfa = 0, qff = 1, qpa = 0, qpf = 1, qaf = 1, qaa = 1, sustain = 1, attack = 0.01|
	var env, aMod, pMod, fMod, carrier;
	env = EnvGen.ar(Env.perc(begin,end), doneAction:2) * amp;
	fMod = LFSaw.ar(qf * qff, 0, qf*qfa);
	pMod = LFSaw.ar(qf * qpf, 0, qpa);
	aMod = Pulse.ar(qf * qaf,0.5,qaa);
	carrier = SinOsc.ar((qf+fMod)/2,pMod); // (/2) makes sy and sya pitch-equiv
	OffsetOut.ar(out,
		DirtPan.ar(carrier*aMod,
			~dirt.numChannels, pan, env));
}).add;)
)

