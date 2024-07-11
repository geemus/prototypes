(
  s.waitForBoot({
    MIDIClient.init;
    MIDIIn.connectAll(verbose:true);
  });
)

(
  ~cc = Bus.control(server:s, numChannels:128);
  MIDIdef.cc(
    key: \cc,
    chan: 0,
    ccNum: #[20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,
    70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94],
    func: {
      |val, num, chan, src|
      "cc - val:% num:% chan:% src:%".format(val, num, chan, src).postln;
      ~cc.setAt(num, val);
    }
  ).permanent_(true);

  ~ccLfoShape = Bus.newFrom(bus:~cc, offset:20, numChannels:1); ~ccLfoShape.set(0);
  ~ccLfoFreq = Bus.newFrom(bus:~cc, offset:21, numChannels:1); ~ccLfoFreq.set(24);
  ~ccLfoMul = Bus.newFrom(bus:~cc, offset:22, numChannels:1); ~ccLfoMul.set(16);

  ~ccfilterFreq = Bus.newFrom(bus:~cc, offset:23, numChannels:1); ~ccFilterFreq.set(20);
  ~ccfilterRq = Bus.newFrom(bus:~cc, offset:27, numChannels:1); ~ccFilterRq.set(64);

  ~vcoFreq = Bus.control(server:s, numChannels:1); ~vcoFreq.set(440.0);
  ~vcoMul = Bus.control(server:s, numChannels:1); ~vcoMul.set(0.25);
  ~vcoGate = Bus.control(server:s, numChannels:1); ~vcoGate.set(1);
  MIDIdef.noteOn(
    key:\keysNoteOn,
    func: {
      |val, num, chan, src|
      var freq = num.midicps;
      var mul = val.linexp(0, 127, 0.01, 0.25);
      var gate = 1;
      //"keysNoteOn - freq:%, mul:%, gate:%".format(freq, mul, gate).postln;
      ~vcoFreq.set(freq);
      ~vcoMul.set(mul);
      ~vcoGate.set(gate);
    },
    chan: 0,
  ).permanent_(true);
  MIDIdef.noteOff(
    key:\keysNoteOff,
    func: {
      |val, num, chan, src|
      var freq = num.midicps;
      var mul = val.linexp(0, 127, 0.01, 0.25);
      var gate = 0;
      //"keysNoteOff - freq:%, mul:%, gate:%".format(freq, mul, gate).postln;
      ~vcoFreq.set(freq);
      ~vcoMul.set(mul);
      ~vcoGate.set(gate);
    },
    chan: 0,
  ).permanent_(true);

  ~lfoOut = Bus.audio(server:s, numChannels:1);
  SynthDef(\lfo, {
    arg ccFreq, ccMul, ccShape, ccFilterFreq, ccFilterRq, outBus;

    var freq = ccFreq.linexp(inMin:0, inMax:127, outMin:1.0, outMax:15000.0);
    var mul = ccMul.linlin(inMin:0, inMax:127, outMin:0.0, outMax:0.3);
    var shape = ccShape.linlin(inMin:0, inMax:127, outMin:0, outMax:2).round;

    var filterFreq = ccFilterFreq.linexp(inMin:0, inMax:127, outMin:20.0, outMax:15000.0);
    var filterRq = ccFilterRq.linlin(inMin:0, inMax:127, outMin:0.01, outMax:1.0);

    var sig = Select.ar(which:shape, array:[
      LFSaw.ar(freq:freq, iphase:0.0, mul:mul, add:0.0),
      LFTri.ar(freq:freq, iphase:0.0, mul:mul, add:0.0),
      LFPulse.ar(freq:freq, iphase:0.0, width: 0.5, mul:mul, add:0.0),
    ]);

    sig = RLPF.ar(in:sig, freq:filterFreq, rq:filterRq, mul:1.0, add:0.0);
    sig = sig ! 2;
    sig = Limiter.ar(in:sig, level:1.0);
    Out.ar(bus:0, channelsArray:sig);
  }).add;

  SynthDef(\vco, {
    arg freq, mul, attack, decay, sustain, release, gate;
    var env, sig;
    sig = SinOsc.ar(freq:freq, phase:0.0, mul:mul, add:0.0);
    env = Env.adsr(
      attackTime:0.01,
      decayTime:0.3,
      sustainLevel:0.5,
      releaseTime:1.0,
    ).kr(doneAction: 0, gate:gate);
    sig = sig * env;
    sig = sig ! 2;
    Out.ar(0, sig);
  }).add
)

(
  ~lfo = Synth.head(
    aGroup:s,
    defName:\lfo,
    args:[
      \ccFreq, ~ccLfoFreq.asMap,
      \ccMul, ~ccLfoMul.asMap,
      \ccShape, ~ccLfoShape.asMap,
      \ccFilterFreq, ~ccFilterFreq.asMap,
      \ccFilterRq, ~ccFilterRq.asMap,
      \outBus, ~lfoOut,
    ]
  );
)

(
  ~vco = Synth.tail(
    aGroup:s,
    defName:\vco,
    args:[
      \freq, ~vcoFreq.asMap,
      \mul, ~vcoMul.asMap,
      \gate, ~vcoGate.asMap,
    ]
  );
)

FreqScope.new;

s.scope;

~lfoOut.scope;

~lfo.free

~vco.free
