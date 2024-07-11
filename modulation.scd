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

  ~ccAttack = Bus.newFrom(bus:~cc, offset:28, numChannels:1); ~ccAttack.set(4);
  ~ccDecay = Bus.newFrom(bus:~cc, offset:29, numChannels:1); ~ccDecay.set(8);
  ~ccSustain = Bus.newFrom(bus:~cc, offset:30, numChannels:1); ~ccSustain.set(16);
  ~ccRelease = Bus.newFrom(bus:~cc, offset:31, numChannels:1); ~ccRelease.set(128);

  ~ccFilterFreq = Bus.newFrom(bus:~cc, offset:23, numChannels:1); ~ccFilterFreq.set(20);
  ~ccFilterRq = Bus.newFrom(bus:~cc, offset:27, numChannels:1); ~ccFilterRq.set(64);

  ~vcoFreq = Bus.control(server:s, numChannels:1); ~vcoFreq.set(440.0);
  ~vcoMul = Bus.control(server:s, numChannels:1); ~vcoMul.set(0.25);
  ~vcaGate = Bus.control(server:s, numChannels:1); ~vcaGate.set(0);
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
      ~vcaGate.set(gate);
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
      ~vcaGate.set(gate);
    },
    chan: 0,
  ).permanent_(true);

  ~lfoOut = Bus.audio(server:s, numChannels:1);
  SynthDef(\lfo, {
    arg ccFreq, ccMul, ccShape, outBus;

    var freq = ccFreq.linexp(inMin:0, inMax:127, outMin:1.0, outMax:15000.0);
    var mul = ccMul.linlin(inMin:0, inMax:127, outMin:0.0, outMax:0.3);
    var shape = ccShape.linlin(inMin:0, inMax:127, outMin:0, outMax:2).round;

    var sig = Select.ar(which:shape, array:[
      LFSaw.ar(freq:freq, iphase:0.0, mul:mul, add:0.0),
      LFTri.ar(freq:freq, iphase:0.0, mul:mul, add:0.0),
      LFPulse.ar(freq:freq, iphase:0.0, width: 0.5, mul:mul, add:0.0),
    ]);

    sig = Limiter.ar(in:sig, level:0.3);
    Out.ar(bus:outBus, channelsArray:sig)
  }).add;

  ~vcoOut = Bus.audio(server:s, numChannels:1);
  SynthDef(\vco, {
    arg freq, mul, lfoBus, outBus;

    var lfo = In.ar(bus:lfoBus, numChannels:1);

    var sig = SinOsc.ar(freq:freq, phase:0.0, mul:mul, add:0.0);

    sig = sig;
    sig = Limiter.ar(in:sig, level:1.0);
    Out.ar(outBus, sig);
  }).add;

  ~vcaOut = Bus.audio(server:s, numChannels:1);
  SynthDef(\vca, {
    arg ccAttack, ccDecay, ccSustain, ccRelease, gate, inBus, outBus;

    var in = In.ar(bus:inBus, numChannels:1);

    var attack = ccAttack.linlin(inMin:0, inMax:127, outMin:0.0, outMax:4.0);
    var decay = ccDecay.linlin(inMin:0, inMax:127, outMin:0.0, outMax:4.0);
    var sustain = ccSustain.linlin(inMin:0, inMax:127, outMin:0.0, outMax:1.0);
    var release = ccRelease.linlin(inMin:0, inMax:127, outMin:0.0, outMax:4.0);

    var env = Env.adsr(
      attackTime:attack,
      decayTime:decay,
      sustainLevel:sustain,
      releaseTime:release,
    ).kr(doneAction: 0, gate:gate);

    var sig = in * env;
    sig = Limiter.ar(in:sig, level:1.0);
    Out.ar(outBus, sig)
  }).add;

  SynthDef(\vcf, {
    arg ccFilterFreq, ccFilterRq, inBus, outBus;

    var in = In.ar(bus:inBus, numChannels:1);

    var filterFreq = ccFilterFreq.linexp(inMin:0, inMax:127, outMin:20.0, outMax:15000.0);
    var filterRq = ccFilterRq.linlin(inMin:0, inMax:127, outMin:0.01, outMax:1.0);

    var sig = RLPF.ar(in:in, freq:filterFreq, rq:filterRq, mul:1.0, add:0.0);
    sig = Limiter.ar(in:sig, level:1.0);
    Out.ar(outBus, sig)
  }).add;
)

(
  ~lfo = Synth.head(
    aGroup:s,
    defName:\lfo,
    args:[
      \ccFreq, ~ccLfoFreq.asMap,
      \ccMul, ~ccLfoMul.asMap,
      \ccShape, ~ccLfoShape.asMap,
      \outBus, ~lfoOut,
    ]
  );

  ~vco = Synth.tail(
    aGroup:s,
    defName:\vco,
    args:[
      \freq, ~vcoFreq.asMap,
      \mul, ~vcoMul.asMap,
      \lfoBus, ~lfoOut,
      \outBus, ~vcoOut,
    ]
  );

  ~vca = Synth.tail(
    aGroup:s,
    defName:\vca,
    args:[
      \ccAttack, ~ccAttack.asMap,
      \ccDecay, ~ccDecay.asMap,
      \ccSustain, ~ccSustain.asMap,
      \ccRelease, ~ccRelease.asMap,
      \gate, ~vcaGate.asMap,
      \lfoBus, ~lfoOut,
      \inBus, ~vcoOut,
      \outBus, ~vcaOut,
    ]
  );

  ~vcf = Synth.tail(
    aGroup:s,
    defName:\vcf,
    args:[
      \ccFilterFreq, ~ccFilterFreq.asMap,
      \ccFilterRq, ~ccFilterRq.asMap,
      \inBus, ~vcaOut,
      \outBus, 0,
    ]
  );
)

~vcaOut.scope;

FreqScope.new;

s.scope;

~lfoOut.scope;

~lfo.free

~vco.free
