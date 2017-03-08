// examples, modded a little, from
// file:///home/jeff/.local/share/SuperCollider/downloaded-quarks/Feedback/Fb.html

// FbNode

b = Buffer.read(s,"/home/jeff/.local/share/SuperCollider/downloaded-quarks/Dirt-Samples/koy/01_left.wav")

({	var in = Decay.ar(Impulse.ar(5))+(0.4*PinkNoise.ar());
	var fbNode = FbNode(1,0.6); // 2nd arg = max delay time (in s)
	var signal = LeakDC.ar(fbNode.delay); // read feedback bus, delay result
	    // delay time defaults to max
	// Add the input to the feedback signal, then filter and distort it.
	signal = LPF.ar(signal*1.05 + in, 1500, 3.8).distort;
	    // fun: scale signal by something > 1
	fbNode.write(signal); // write the signal to the feedback buffer
	DetectSilence.ar(signal ,doneAction:2);
	signal!2;
}.play; )


// basic usage without adding a delay line: self-modulating sine wave.
({	var fbNode = FbNode(1);
	var signal = SinOsc.ar(300, fbNode * Line.kr(0,2,10) );
		// the FbNode is used to modulate the SinOsc's phase
	fbNode.write(signal);
	signal ! 2;
}.play;)

({	var fbNode = FbNode(); // ** change freq: vary chaos
	var leaked = LeakDC.ar(fbNode);
	var signal = Pulse.ar(leaked+2*40, leaked/4+0.2 );
	fbNode.write(signal);
	signal ! 2;
}.play;)


// Crosstalk!
({	var in = BrownNoise.ar*Line.kr(1,0,0.15);
	var fbNode1 = FbNode(1,9/8);
	var fbNode2 = FbNode(1,0.003);
	var sig1 = in + (fbNode1.delay * 0.8) + (fbNode2.delay * 0.2);
	var sig2 = in + (fbNode1.delay * 0.1) + (fbNode2.delay * 0.9);
	fbNode1.write(sig1);
	fbNode2.write(sig2);
	Pan2.ar(sig1, -0.8) + Pan2.ar(sig2, 0.8);
}.play;
)



// -- Fb
({	var sig = Impulse.ar(0);
	var freq = 100;
	sig = FbL(
		{arg fb; LPF.ar(LeakDC.ar(fb),500)*0.99997+sig;},
		1/freq);
	DetectSilence.ar(sig,doneAction:2);
	sig*64;
}.play)

({	var sig = Impulse.ar(0);
	sig = FbL({arg fb; LPF.ar(LeakDC.ar(fb),8000)*0.99+sig;},1/300);
	sig = FbL({arg fb; LPF.ar(LeakDC.ar(fb),8000)*0.99+sig;},1/400);
	sig = FbL({arg fb; LPF.ar(LeakDC.ar(fb),8000)*0.99+sig;},1/500);
	DetectSilence.ar(sig,doneAction:2);
	sig!2;
}.play)

({	var sig = Decay.kr(Impulse.kr(1/2),0.6)*BrownNoise.ar(1!2);
	sig = FbL({
		arg fb1;
		sig = sig + FbL({
			arg fb2;
			(OnePole.ar(LeakDC.ar(0-fb2),0.2)*0.9995*1)+(fb1*9) / 10;},
		1/250);
		OnePole.ar(sig,-0.01);
	},1/(LFSaw.ar(60)*5+40));
	sig;
}.play;)