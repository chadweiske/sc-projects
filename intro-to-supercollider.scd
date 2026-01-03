s.boot;
s.meter;
s.scope;
s.volume.gui;

o = Server.default.options;
o.inDevice_("Windows WASAPI : Microphone");
o.outDevice_("Windows WASAPI : Speakers");
Server.default.reboot;

ServerOptions.devices;

Server.default.options.outDevice = "MME : StudioLive WDM 1/2 (StudioLive";

// Test Tones
// Phase-Coherent Pink Noise

{[PinkNoise.ar(0.2)]!2}.play;

// True Stereo Pink Noise

{[PinkNoise.ar(0.2), PinkNoise.ar(0.2)]}.play;

// Phase-Coherent Brown Noise

{[BrownNoise.ar(0.2)]!2}.play;

// True Stereo Brown Noise

{[BrownNoise.ar(0.2), BrownNoise.ar(0.2)]}.play;

// Path persistence for sample playback

thisProcess.nowExecutingPath;

PathName(thisProcess.nowExecutingPath).parentPath;

PathName(thisProcess.nowExecutingPath).parentPath ++ "audio";

~audiopath = PathName(thisProcess.nowExecutingPath).parentPath ++ "audio/";

(
~voice = Buffer.read(s, ~audiopath ++ "");
)



// "My Bullshit Sound" or whatever...

(
~mySound = {
	arg freq3 = 175;
	[SinOsc.ar(freq3, 0, 0.2), SinOsc.ar(freq3 + 10, 0, 0.2)];
};
)

~mySound.play;

~mySound.plot(3);
x.free;

// LFO

(
~trem = {
	var freq2 = 5;
	[SinOsc.ar(freq2, 0, 0.2)];
};
)

// Week 3

// Implicit

(
~fn = {
	arg freq=200, offset=2, lpf=1500, amp=0.2;
	var sig;
	sig = Saw.ar(freq + [0, offset]);
	sig = LPF.ar(sig, lpf);
	sig = sig * amp;
}
)

x = ~fn.play(args: [\freq, 150]);
x.free;



// Explicit SynthDef

(
SynthDef.new(\saw, {
	arg freq=200, gate=1, offset=2, lpf=1500, amp=0.2, out=0;
	var sig, env;
	env = 	EnvGen.ar(
		Env.new(
			[0, 1, 0.5, 0],
			[1, 1, 1],
			[1, -2, -3],
			2
		),
		gate,
		doneAction:2
	);
	sig = Saw.ar(freq + [0, offset]);
	sig = LPF.ar(sig, lpf);
	sig = sig * amp;
	sig = sig * env;
	Out.ar(out, sig);
};
).add;
)

(
[x = Synth.new(\saw, [\freq, 40, \lpf, 64]),
	x = Synth.new(\saw, [\freq, 40, \lpf, 128]),
x = Synth.new(\saw, [\freq, 40, \lpf, 256]),
x = Synth.new(\saw, [\freq, 40, \lpf, 512]),
x = Synth.new(\saw, [\freq, 40, \lpf, 1000]),
x = Synth.new(\saw, [\freq, 40, \lpf, 2000]),
x = Synth.new(\saw, [\freq, 40, \lpf, 4000]),
x = Synth.new(\saw, [\freq, 40, \lpf, 8000]),
x = Synth.new(\saw, [\freq, 40, \lpf, 16000])]

x.set(\gate, 0);

//=================

(
~notes = [43, 45, 47, 55, 59, 61, 62, 64, 66, 69, 71, 76];
~synths = ~notes.collect({
	arg n;
	Synth.new(\saw, [\freq, n.midicps, \lpf, 3000]);
});
)

// Collect returns a new modified collection

(
~synths.collect({
	arg n;
	n.set(\gate, 0);
});
)

// Do always returns it's receiver, the thing it operates on

(
~synths.do({
	arg n;
	n.set(\gate, 0);
});
)

s.options.blockSize / s.sampleRate;

//

(
f = {
	var sig, mod, modhz;
	modhz = MouseX.kr(1, 4000, 1);
	mod = SinOsc.kr(modhz).bipolar(400);
	sig = SinOsc.ar(500 + mod);
	sig = sig * 0.2;
}.play;
)

// Week 5
// Sample Playback

b.free;

b = Buffer.read(s, "");

b.play;
b.query;

thisProcess.nowExecutingPath;

PathName(thisProcess.nowExecutingPath).parentPath;

PathName(thisProcess.nowExecutingPath).parentPath ++ "audio/";

~audiopath = PathName(thisProcess.nowExecutingPath).parentPath ++ "audio/";

Buffer.freeAll;

//(
//b = [
//    Buffer.read(s, ~audiopath ++ ""),
//    Buffer.read(s, ~audiopath ++ "")
//];
//)
//
//b[0].play;
//b[1].play;

Buffer.freeAll;

(
b = (
	BD: Buffer.read(s, ~audiopath ++ "BD A 808 Decay C 04.wav"),
    BD2: Buffer.read(s, ~audiopath ++ "BD A 808 Decay F 04.wav"),
	SN: Buffer.read(s, ~audiopath ++ "Snare 8.wav"),
	CH: Buffer.read(s, ~audiopath ++ "CH Combo 808.wav"),
	OH: Buffer.read(s, ~audiopath ++ "OH 808 Decay 05.wav")
	)
)

b[\BD].play;
b[\BD2].play;
b[\SN].play;
b[\CH].play;
b[\OH].play;

///////////

(
SynthDef.new(\play, {
	arg buf=0;
	var sig:
	sig = PlayBuf.ar(1, buf);
	Out.ar(0, sig);
}).add;
)

Synth.new(\play, [\buf, b[\voice]]);

x.set(\t_trig, 1, \spos, rrand(0, b[\voice].numFrames - 1));

(
SynthDef.new(\play2, {
    arg buf=0, rate=1, spos=0;
    var sig, trig;
    trig = Impulse.kr(4);
    sig = PlayBuf.ar(2, buf, rate, trig, spos);
    Out.ar(0, sig);
}).add;
)

x = Synth.new(\play2, [\buf, b[\voice], \rate, 1, \spos, 48000]);
b[\voice].numFrames;

(
SynthDef.new(\play2, {
    arg buf=0, rate=1;
    var sig, trig, env, spos;
    trig = Impulse.kr(2);
    spos = TIRand.kr(0, BufFrames.kr(buf) - 1, trig);
    env = EnvGen.kr(
        Env.new([0, 1, 0], [0.01, 0.5], [1, -2]),
        trig
    );
    sig = PlayBuf.ar(2, buf, rate, trig, spos);
    sig = sig * env;
    Out.ar(0, sig);
}).add;
)
