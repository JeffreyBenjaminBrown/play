{ LFTri.ar(LFTri.kr(LFTri.kr(0.2,0,8,10),0, 400,800),0,0.1) }.scope(1, zoom: 4);
{ LFTri.ar(LFTri.kr(0.2, 0, 400,800),0,0.1) }.scope(1, zoom: 4);
{ LFTri.ar(800,0,0.1) }.scope(1, zoom: 4);
{ LFTri.ar(XLine.kr(10,1000,6),0,0.1) }.scope(1, zoom: 4);


{ SinOsc.ar(400*Impulse.ar(300,0,0.1)) }.play();

{ Pulse.ar(500,Pulse.kr(4,0.5,1,1))*Pulse.ar(600)}.play();

{Pulse.ar(LFPulse.ar(300,0,0.1,200,00),LFSaw.ar(40,0.5,1,1))*SinOsc.ar(400)}.play();


{ Impulse.ar(100,0,0.1) }.scope(1, zoom: 4);

{Impulse.ar(1400)+Impulse.ar(1300)}.play();
{ Blip.ar(108)}.play();


{LFPar.ar(
	LFNoise0.ar(60,100,200),
	0, 0.2)
}.play();

{LFPar.ar(
	200+(1000*Crackle.ar(1.9)),
	0, 0.2)
}.play();

{ Klank.ar(`[ 4000/(6..11), nil, nil ], ClipNoise.ar(0.007)) }.scope(1);

