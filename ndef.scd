(
  s.waitForBoot({
    s.sync;
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

  ~ccFilterFreq = Bus.newFrom(bus:~cc, offset:23, numChannels:1); ~ccFilterFreq.set(127);
  ~ccFilterRq = Bus.newFrom(bus:~cc, offset:27, numChannels:1); ~ccFilterRq.set(64);

  ~ccVcaAmp = Bus.newFrom(bus:~cc, offset:24, numChannels:1); ~ccVcaAmp.set(64);

  ~vcoFreq = Bus.control(server:s, numChannels:1); ~vcoFreq.set(440.0);
  ~vcoMul = Bus.control(server:s, numChannels:1); ~vcoMul.set(0.25);
  ~envGate = Bus.control(server:s, numChannels:1); ~envGate.set(0);
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
      ~envGate.set(gate);
    },
    chan: 0,
  ).permanent_(true);
  MIDIdef.noteOff(
    key:\keysNoteOff,
    func: {
      |val, num, chan, src|
      var freq = num.midicps;
      var mul = val.linlin(0, 127, 0.01, 0.25);
      var gate = 0;
      //"keysNoteOff - freq:%, mul:%, gate:%".format(freq, mul, gate).postln;
      ~vcoFreq.set(freq);
      ~vcoMul.set(mul);
      ~envGate.set(gate);
    },
    chan: 0,
  ).permanent_(true);

  Ndef.new(key:\lfo, object:{
    var freq = \ccFreq.kr(0).linexp(inMin:0, inMax:127, outMin:1.0, outMax:15000.0);
    var mul = \ccMul.kr(24).linlin(inMin:0, inMax:127, outMin:0.0, outMax:0.25);
    var shape = \ccShape.kr(16).linlin(inMin:0, inMax:127, outMin:0, outMax:2).round;

    var sig = Select.ar(which:shape, array:[
      LFSaw.ar(freq:freq, iphase:0.0, mul:mul, add:0.0),
      LFTri.ar(freq:freq, iphase:0.0, mul:mul, add:0.0),
      LFPulse.ar(freq:freq, iphase:0.0, width: 0.5, mul:mul, add:0.0),
    ]);

    sig = Limiter.ar(in:sig, level:0.3);
  }).map(
    \ccFreq, ~ccLfoFreq.asMap,
    \ccMul, ~ccLfoMul.asMap,
    \ccShape, ~ccLfoShape.asMap,
  );

  Ndef.new(key:\vco, object:{
    var sig = SinOsc.ar(freq:\freq.kr(440.0), phase:0.0, mul:\mul.kr(0.5), add:0.0);
    sig = Limiter.ar(in:sig, level:1.0);
  }).map(
    \freq, ~vcoFreq.asMap,
    \mul, ~vcoMul.asMap,
  );

  Ndef.new(key:\env, object:{
    var env = Env.adsr(
      attackTime:\ccAttack.kr(4).linlin(inMin:0, inMax:127, outMin:0, outMax:4.0),
      decayTime:\ccDecay.kr(8).linlin(inMin:0, inMax:127, outMin:0, outMax:4.0),
      sustainLevel:\ccSustain.kr(16).linlin(inMin:0, inMax:127, outMin:0, outMax:1.0),
      releaseTime:\ccRelease.kr(128).linlin(inMin:0, inMax:127, outMin:0.2, outMax:4.0),
    ).kr(doneAction: Done.freeSelf(), gate:\noteGate.kr(0));

    var sig = \in.ar(0) * env;
    Limiter.ar(in:sig, level:1.0);
  }).map(
    \ccAttack, ~ccAttack.asMap,
    \ccDecay, ~ccDecay.asMap,
    \ccSustain, ~ccSustain.asMap,
    \ccRelease, ~ccRelease.asMap,
    \noteGate, ~envGate.asMap,
  );

  Ndef.new(key:\vcf, object:{
    var filterFreq = \ccFilterFreq.kr(20).linexp(inMin:0, inMax:127, outMin:20.0, outMax:15000.0);
    var filterRq = \ccFilterRq.kr(64).linlin(inMin:0, inMax:127, outMin:0.01, outMax:1.0);

    var sig = RLPF.ar(in:\in.ar(0), freq:filterFreq, rq:filterRq, mul:1.0, add:0.0);
    sig = Limiter.ar(in:sig, level:1.0);
  }).map(
    \ccFilterFreq, ~ccFilterFreq.asMap,
    \ccFilterRq, ~ccFilterRq.asMap,
  );

  Ndef.new(key:\vca, object:{
    var amp = \ccVcaAmp.kr(64).linlin(inMin:0, inMax:127, outMin:0, outMax:20);
    \in.ar(0) * amp.dbamp;
  }).map(
    \ccVcaAmp, ~ccVcaAmp.asMap,
  );
)
Ndef(\lfo).play;
Ndef(\lfo).stop(1.0);

Ndef(\vco).play;
Ndef(\vco).stop(1.0);

Ndef(\vco) <>>.in Ndef(\env); Ndef(\env).play;
Ndef(\env).stop(1.0);

Ndef(\vco) <>>.in Ndef(\vcf); Ndef(\vcf).play;
Ndef(\vco) <>>.in Ndef(\env) <>>.in Ndef(\vcf) <>>.in Ndef(\vca); Ndef(\vca).play;
Ndef(\vca).stop(1.0);

Ndef(\vco) <>>.in Ndef(\vcf) <>>.in Ndef(\vca); Ndef(\vca).play;
Ndef(\vca).stop(1.0);

Ndef(\lfo).scope;
Ndef(\vco).scope;
Ndef(\env).scope;
Ndef(\vcf).scope;

NdefMixer(s);

FreqScope.new;

s.scope;

~lfoOut.scope;
