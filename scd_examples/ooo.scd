// source: https://depts.washington.edu/dxscdoc/Help/Guides/Order-of-execution.html

s.boot;

(
l = Bus.control(s, 1);  // get a bus for the LFO--not relevant to order-of-exec
b = Bus.audio(s, 2);    // assuming stereo--this is to keep the src->fx chain separate from
                // other similar chains
~synthgroup = Group.tail(s);
~fxgroup = Group.tail(s);

// now you have synthgroup --> fxgroup within the default group of s

// make some synthdefs to play with
SynthDef("order-of-ex-dist", { arg bus, preGain, postGain;
    var sig;
    sig = In.ar(bus, 2);
    sig = (sig * preGain).distort;
    ReplaceOut.ar(bus, sig * postGain);
}).add;

SynthDef("order-of-ex-pulse", { arg freq, bus, ffreq, pan, lfobus;
    var sig, noteLen;
    noteLen = In.kr(lfobus, 1);
    sig = RLPF.ar(Pulse.ar(freq, 0.2, 0.5), ffreq, 0.3);
    Out.ar(bus, Pan2.ar(sig, pan)
        * EnvGen.kr(Env.perc(0.1, 1), timeScale: noteLen, doneAction: Done.freeSelf));
}).add;

SynthDef("LFNoise1", { arg freq, mul, add, bus;
    Out.kr(bus, LFNoise1.kr(freq, mul:mul, add:add));
}).add;
)

// Place LFO:

~lfo = Synth.head(s, "LFNoise1", [\freq, 0.3, \mul, 0.68, \add, 0.7, \bus, l]);

// Then place your effect:

~dist = Synth.tail(~fxgroup, "order-of-ex-dist", [\bus, b, \preGain, 8, \postGain, 0.6]);

// transfer the results to main out, with level scaling
// play at tail of s's default group (note that Function-play also takes addActions!

~xfer = { Out.ar(0, 0.25 * In.ar(b, 2)) }.play(s, addAction: \addToTail);

(
r = Routine({
  {
    Synth.tail(~synthgroup, "order-of-ex-pulse", [\freq, rrand(200, 800), \ffreq, rrand(1000, 15000), \pan, 1.0.rand2, \bus, b, \lfobus, l]);
    0.07.wait;
  }.loop;
}).play(SystemClock);
)

~dist.run(false);    // proves that the distortion effect is doing something
~dist.run(true);

// to clean up:
(
r.stop;
[~synthgroup, ~fxgroup, b, l, ~lfo, ~xfer].do({ arg x; x.free });
currentEnvironment.clear; // clear all environment variables
)
