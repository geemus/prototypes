(
  s.waitForBoot({
    ~notes = Array.newClear(indexedSize:128);
    MIDIClient.init;
    MIDIIn.connectAll(verbose:true);
  });
)

(
  ~lfoShape = Bus.control(server:s, numChannels:1); ~lfoShape.set(0.0);
  MIDIdef.cc(
    key:\lfoShape,
    func: {
      |val, num, chan, src|
      var shape = val.linlin(inMin:0, inMax:127, outMin:0, outMax:2).round;
      ["lfoArgShape:", shape].postln;
      ~lfoShape.set(shape);
    },
    ccNum: #[20],
    chan: 0,
  ).permanent_(true);

  ~lfoFreq = Bus.control(server:s, numChannels:1); ~lfoFreq.set(440.0);
  MIDIdef.cc(
    key:\lfoFreq,
    func: {
      |val, num, chan, src|
      var freq = val.linexp(inMin:0, inMax:127, outMin:1.0, outMax:15000.0);
      ["lfoArgFreq:", freq].postln;
      ~lfoFreq.set(freq);
    },
    ccNum: #[21],
    chan: 0,
  ).permanent_(true);

  ~lfoMul = Bus.control(server:s, numChannels:1); ~lfoMul.set(0.15);
  MIDIdef.cc(
    key:\lfoMul,
    func: {
      |val, num, chan, src|
      var mul = val.linlin(inMin:0, inMax:127, outMin:0.0, outMax:0.3);
      ["lfoArgMul:", mul].postln;
      ~lfoMul.set(mul);
    },
    ccNum: #[22],
    chan: 0,
  ).permanent_(true);

  ~filterFreq = Bus.control(server:s, numChannels:1); ~filterFreq.set(440.0);
  MIDIdef.cc(
    key:\filterFreq,
    func: {
      |val, num, chan, src|
      var freq = val.linexp(inMin:0, inMax:127, outMin:20.0, outMax:15000.0);
      ["filterArgFreq:", freq].postln;
      ~filterFreq.set(freq);
    },
    ccNum: #[23],
    chan: 0,
  ).permanent_(true);

  ~filterRq = Bus.control(server:s, numChannels:1); ~filterRq.set(0.5);
  MIDIdef.cc(
    key:\filterRq,
    func: {
      |val, num, chan, src|
      var rq = val.linlin(inMin:0, inMax:127, outMin:0.01, outMax:1.0);
      ["filterArgRq:", rq].postln;
      ~filterRq.set(rq);
    },
    ccNum: #[27],
    chan: 0,
  ).permanent_(true);

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
    arg freq, mul, shape, filterFreq, filterRq, outBus;
    var sig;
    sig = Select.ar(which:shape, array:[
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
      \freq, ~lfoFreq.asMap,
      \mul, ~lfoMul.asMap,
      \shape, ~lfoShape.asMap,
      \filterFreq, ~filterFreq.asMap,
      \filterRq, ~filterRq.asMap,
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
