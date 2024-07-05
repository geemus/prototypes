(
  s.waitForBoot({
    ~notes = Array.newClear(indexedSize:128);
    MIDIClient.init;
    MIDIIn.connectAll(verbose:true);
  });
)

(
  ~lfoArgFreqBus = Bus.control(server:s, numChannels:1); ~lfoArgFreqBus.set(440.0);
  MIDIdef.cc(
    key:\lfoArgFreq,
    func: {
      |val, num, chan, src|
      var freq = val.linexp(inMin:0, inMax:127, outMin:1.0, outMax:2000.0);
      freq.postln;
      ~lfoArgFreqBus.set(freq);
    },
    ccNum: #[20],
    chan: 0,
  ).permanent_(true);

  ~lfoArgMulBus = Bus.control(server:s, numChannels:1); ~lfoArgMulBus.set(0.5);
  MIDIdef.cc(
    key:\lfoArgMul,
    func: {
      |val, num, chan, src|
      var mul = val.linlin(inMin:0, inMax:127, outMin:0, outMax:1);
      mul.postln;
      ~lfoArgMulBus.set(mul);
    },
    ccNum: #[21],
    chan: 0,
  ).permanent_(true);

  ~lfoOutBus = Bus.audio(server:s, numChannels:1);
  SynthDef(\lfo, {
    arg argFreq, argMul, outBus;
    var sig;
    sig = SinOsc.ar(
      freq:argFreq,
      phase:0.0,
      mul:argMul,
      add:0.0
    );
    Out.ar(bus:outBus, channelsArray:sig);
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
      \outBus, ~lfoOutBus,
  ]);
)

s.scope;

~lfoOutBus.scope;

~lfo.free
