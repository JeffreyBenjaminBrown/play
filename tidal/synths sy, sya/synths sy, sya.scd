(
s.options.numBuffers = 1024 * 1024; // originally was 1024 * 64
SuperDirt.start;

// warning: do not try to unify qf with the preexisting speed symbol
// speed has its own effect elsewhere, so it would serve double-duty, and the effects are unmusical

(SynthDef(\sy,	{ // by default, sine wave
	|out, pan, qa=1, qf=440,
	qfa = 0, qff = 1, qpa = 0, qpf = 1, qaa = 0, qaf = 1,
	sustain = 1, attack = 0.01|
	var env, aMod, pMod, fMod, carrier;
	env = EnvGen.ar(Env.perc(0.01,0.99), timeScale: sustain) * qa;
	fMod = LFSaw.ar(qf * qff, 0, qf*qfa); // freq mod, hence big amplitude
	pMod = LFSaw.ar(qf * qpf, 0, qpa); // phase mod
	aMod = 1+(qaa*Pulse.ar(qf * qaf,0.5,2,-1)); // amp mod, bandlimited(not LF)
	  // if qaa = 0, this has no effect (unlike sya)
	carrier = SinOsc.ar(qf+fMod,pMod);
	OffsetOut.ar(out,
		DirtPan.ar(1*carrier*aMod,
			~dirt.numChannels, pan, env));
}).add;);

// With default amp mod (qaa), this sounds an octave higher than sy.
  // There's no natural way to bring them in line with each other.
(SynthDef(\sya,	{
	|out, pan, qa=1, qf=440, begin = 0, end = 1,
	qfa = 0, qff = 1, qpa = 0, qpf = 1, qaf = 1, qaa = 1,
	sustain = 1, attack = 0.01|
	var env, aMod, pMod, fMod, carrier;
	env = EnvGen.ar(Env.perc(0.01,0.99), timeScale: sustain) * qa;
	fMod = LFSaw.ar(qf * qff, 0, qf*qfa);
	pMod = LFSaw.ar(qf * qpf, 0, qpa);
	aMod = Pulse.ar(qf * qaf,0.5,qaa);
	carrier = SinOsc.ar((qf+fMod),pMod);
	OffsetOut.ar(out,
		DirtPan.ar(carrier*aMod,
			~dirt.numChannels, pan, env));
}).add;)
)
