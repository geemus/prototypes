(
  s.waitForBoot({
    ~notes = Array.newClear(indexedSize:128);
    MIDIClient.init;
    MIDIIn.connectAll(verbose:true);
  });
)

(
  ~lfoArgShapeBus = Bus.control(server:s, numChannels:1); ~lfoArgShapeBus.set(0.0);
  MIDIdef.cc(
    key:\lfoArgShape,
    func: {
      |val, num, chan, src|
      var shape = val.linlin(inMin:0, inMax:127, outMin:0, outMax:2).round;
      ["lfoArgShape:", shape].postln;
      ~lfoArgShapeBus.set(shape);
    },
    ccNum: #[20],
    chan: 0,
  ).permanent_(true);

  ~lfoArgFreqBus = Bus.control(server:s, numChannels:1); ~lfoArgFreqBus.set(440.0);
  MIDIdef.cc(
    key:\lfoArgFreq,
    func: {
      |val, num, chan, src|
      var freq = val.linexp(inMin:0, inMax:127, outMin:1.0, outMax:15000.0);
      ["lfoArgFreq:", freq].postln;
      ~lfoArgFreqBus.set(freq);
    },
    ccNum: #[21],
    chan: 0,
  ).permanent_(true);

  ~lfoArgMulBus = Bus.control(server:s, numChannels:1); ~lfoArgMulBus.set(0.5);
  MIDIdef.cc(
    key:\lfoArgMul,
    func: {
      |val, num, chan, src|
      var mul = val.linlin(inMin:0, inMax:127, outMin:0, outMax:1);
      ["lfoArgMul:", mul].postln;
      ~lfoArgMulBus.set(mul);
    },
    ccNum: #[22],
    chan: 0,
  ).permanent_(true);

  ~lfoOutBus = Bus.audio(server:s, numChannels:1);
  SynthDef(\lfo, {
    arg argFreq, argMul, argShape, outBus;
    var sig;
    sig = Select.ar(which:argShape, array:[
      LFSaw.ar(freq:argFreq, iphase:0.0, mul:argMul, add:0.0),
      LFTri.ar(freq:argFreq, iphase:0.0, mul:argMul, add:0.0),
      LFPulse.ar(freq:argFreq, iphase:0.0, width: 0.5, mul:argMul, add:0.0),
    ]);
    Out.ar(bus:0, channelsArray:sig);
  }).add;
)

(
  ~lfo = Synth.head(
    aGroup:s,
    defName:\lfo,
    args:[
      \argFreq, ~lfoArgFreqBus.asMap,
      \argMul, ~lfoArgMulBus.asMap,
      \argShape, ~lfoArgShapeBus.asMap,
      \outBus, ~lfoOutBus,
  ]);
)

s.scope;

~lfoOutBus.scope;

~lfo.free
