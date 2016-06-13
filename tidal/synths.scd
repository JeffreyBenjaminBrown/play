// sccode.org/1-j
n=LFNoise1;Ndef(\x,{a=SinOsc.ar(65,Ndef(\x).ar*n.ar(0.1,3),n.ar(3,6)).tanh;9.do{a=AllpassL.ar(a,0.3,{0.2.rand+0.1}!2,5)};a.tanh}).play

// JITLib ("just in time" lib), proxies, ndef: use?
// e.g. to live-code a crossfade **
// Ndef, from help files
Ndef(\a).play; // play to hardware output.
Ndef(\a).fadeTime = 2; // fadeTime specifies crossfade
// set the source
Ndef(\a, { SinOsc.ar([350, 351.3], 0, 0.2) });
Ndef(\a, { Pulse.ar([350, 351.3] / 4, 0.4, 0.2) });
Ndef(\a, Pbind(\dur, 0.03, \freq, Pbrown(0, 1, 0.1, inf).linexp(0, 1, 200, 350)));
Ndef(\a, { Ringz.ar(Ndef.ar(\b), [350, 351.3] * 2, 0.4) });
Ndef(\b, { Impulse.ar([5, 7]/2, [0, 0.5], 0.15) });
Ndef.clear(3); // clear all after 3 seconds

// 07, Thor Magnusson
({x=SinOsc;y=LFNoise0;a=y.ar(8);
	(x.ar(
		Pulse.ar(1/2)*30)+x.ar(400+(a*50))//last~pitch
	+ (1*MoogFF.ar(
		Pulse.ar(y.ar(4,333,666)),
		a*XLine.ar(1,39,99,99,0,2)))
)!2/3}.play())

{Pulse.ar(80,LFSaw.ar(1000/7)*8)}.play(); // ** ??

{x=SinOsc; x.ar(x.ar()*400)}.play(); // ??
{x=SinOsc; SinOsc.ar(SinOsc.ar()*400)}.play(); // ??
{Pulse.ar((LFSaw.ar(1/2)*5).floor*15+120)}.play();
{SinOsc.ar(180)}.play()

{x=SinOsc; x.ar(x.ar()*400)}.play(); // ??
{x=SinOsc; SinOsc.ar(SinOsc.ar()*400)}.play(); // ??

{SinOsc.ar((LFSaw.ar(1/5)*4).floor*100+800)}.play

({	var source,local; x=SinOsc; y=Pulse;
	source=x.ar(
		y.ar(300)*BrownNoise.ar()
		+x.ar(400)
		*500);
	local = LocalIn.ar(1)*1.2 + source;
	source = local * source;
	LocalOut.ar(
		DelayN.ar(
			LPF.ar(local+source,500),
			1,0.1));
	local
}.play)

{Pulse.ar(1)}.play()

// ** the 50,75,750 are tuned
{Pulse.ar((LFSaw.ar(1/4)*8).floor*75+750)	*SinOsc.ar((LFSaw.ar(1/8)*(-12)).floor*300+75)}.play();

{Pulse.ar((LFSaw.ar(1/4)*8).floor*75+750)}.play()
{Pulse.ar((LFSaw.ar(1/4)*(-12)).floor*300+75)}.play();

({  var source, local; // FEEDBACK!
	source = Decay.ar(Impulse.ar(10), 0.3) * BrownNoise.ar(0.2);
	local = LocalIn.ar(2) + [source, PinkNoise.ar()*LFSaw.ar(90)]; // read feedback, add to source
	local = BRF.ar(DelayN.ar(local,1,0.1).distort,5000); // delay sound
	// reverse channels to give ping pong effect, apply decay factor
	LocalOut.ar(local.reverse * 2.1 * Saw.ar(80));
	Out.ar(0, local);
}.play;)

({  var source, local; // TUNED: 0.012 ~ 74.5
	    source = Decay.ar(Impulse.ar(1), 0.1) * BrownNoise.ar(0.2);
	    local = LocalIn.ar(2) + [source, 0]; // read feedback, add to source
    local = DelayN.ar(local, 0.1, 0.012).distort; // delay sound
    // reverse channels to give ping pong effect, apply decay factor
	    LocalOut.ar(local.reverse * 0.997 * SinOsc.ar(74.5));
    Out.ar(0, local);
}.play;)

({LocalOut.ar( // ** becomes chaotic
	x=CombN.ar(
		BPF.ar(
			LocalIn.ar(2)*7.5+SinOsc.ar([60,70],0.2),
			3**LFNoise0.kr(4/3,4)*200,
			2).distort,
		3,3.5,40));
x}.play)

({LocalOut.ar( //**
	a=CombL.ar(
		LPF.ar(
			LocalIn.ar(2)*7.5+GrayNoise.ar(),
			400,
			0.9).distort
		* Pulse.ar(2),
		2,0.05,40)
);a}.play();)

{Pulse.ar([100,101])}.play()

// 01, Nathaniel Virgo
({LocalOut.ar(
	a=CombL.ar(
		BPF.ar(
			LocalIn.ar(2)*7.5+Saw.ar([32,33],0.2),
			2**LFNoise0.kr(4/3,4)*300,
			0.1).distort,
		2,2,40)
);a}.play();)

{Pulse.ar(LFNoise0.kr([9,3],4)*100+500)}.play()

// tweets from sc140

(SynthDef(\sya,	{
	|out, pan, amp = 1, qf=440, begin = 0, end = 1,
	qfa = 0, qff = 1, qpa = 0, qpf = 1, qaf = 1|
	var env, aMod, pMod, fMod, carrier;
	env = EnvGen.ar(Env.perc(begin,end), doneAction:2) * amp;
	// carrier = LFSaw.ar(qf); //wks: qf+fMod
	aMod = abs(Pulse.ar(qf)) * Pulse.ar(qf/8);
	OffsetOut.ar(out,
		DirtPan.ar(aMod,
			~dirt.numChannels, pan, 1));
}).add;)

// june 12

// first day

// Feedback!
({ // compare pitch
    SinOsc.ar(440, 0, 0.2)
}.play(s, 1);)
({  var in, imp, sound;
	in = LocalIn.ar(1) + (PinkNoise.ar()*0.4);
	imp = Impulse.ar(520); // a secondary pitch
	sound = (DelayC.ar(imp+(in * 1.3).distort,
		1, // ! -ControLDur for correct tuning
		400.reciprocal - ControlDur.ir));     LocalOut.ar(sound); // for feedback
    in
}.play;
)

// Another feedback.
({var input, fbIn, fbOut, procg;
	input = Crackle.ar(1.5,0.5);
	fbIn = LocalIn.ar(1);
p	procg = input + LeakDC.ar((fbIn * MouseX.kr(0,1.05)));
	fbOut = LocalOut.ar(procg);
	Out.ar([0,1],procg)
}.play();)

(SynthDef(\syb,	{
	|out, pan, amp = 1, begin = 0, end = 1, qf=440,
	qfa = 0, qff = 1, qpa = 0, qpf = 1, qaf = 1|
	var ns, env, aMod, pMod, fMod, carrier;
	//fMod = LFSaw.ar(qf * qff, 0, qf*qfa); // freq mod, BIG num
	//env = EnvGen.ar(Env.perc(begin,end), doneAction:2) * amp;
	aMod = 1+LFSaw.ar(qf/5+2*BrownNoise.ar());
	carrier = LFSaw.ar(2*qf*Pulse.ar(qf)
		, LFSaw.ar(qf/6)
	); //wks: qf+fMod
	OffsetOut.ar(out,
		DirtPan.ar(carrier*aMod,
			~dirt.numChannels, pan, amp));
}).add;)

(
// Dust randomly triggers Decay to create an exponential
// decay envelope for the WhiteNoise input source
{
z = Decay.ar(Dust.ar(1,0.5), 0.3, WhiteNoise.ar);
DelayN.ar(z, 0.1, 0.1, 1, z); // input is mixed with delay via the add input
}.play
)

