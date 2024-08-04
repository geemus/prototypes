(
  s.waitForBoot({
    ~notes = Array.newClear(indexedSize:128);
    MIDIClient.init;
  });
)
(
  MIDIIn.connectAll(verbose:true);
)
(
  ~lfo_freq = Bus.control(server:s, numChannels:1);
  MIDIdef.cc(
    key: \lfo_freq,
    chan: 0,
    ccNum: #[20],
    func: {
      |val, num, chan, src|
      var freq = LinExp.kr(in:val, srclo:0, srchi:127, dstlo:1, dsthi:2000);
      [\lfo_freq, val, num, chan, src, "|", freq].postln;
      ~lfo_freq.set(freq);
    }
  ).permanent_(true);

  ~lfo_mul = Bus.control(server:s, numChannels:1);
  MIDIdef.cc(
    key: \lfo_mul,
    chan: 0,
    ccNum: #[21],
    func: {
      |val, num, chan, src|
      var mul = LinLin.kr(in:val, srclo:0, srchi:127, dstlo:0, dsthi:1);
      [\lfo_mul, val, num, chan, src, "|", mul].postln;
      ~lfo_mul.set(mul);
    }
  ).permanent_(true);

  ~lfo = Bus.audio(server:s, numChannels:1);
  SynthDef(\lfo, {
    arg freq = 10, mul = 0.5;
    var sig;
    sig = SinOsc.ar(freq:freq, phase:0.0, mul:mul, add:0.0).range(-1,1);
    sig = sig * 0.2;
    Out.ar(bus:~lfo, channelsArray:sig);
  }).add;
  Synth.head(s, \lfo).map(
    \freq, ~lfo_freq,
    \mul, ~lfo_mul,
  );
  s.scope;

  SynthDef(\vco, {
    arg buf = 0, gate = 1, amp = 0.2, freq = 220, rel = 0.3, out = 0, lfoBus;
    var sig, env, lfo;
    env = Env.asr(0.002, 1, rel).kr(2, gate);
    lfo = In.ar(bus:lfoBus, numChannels:1);
    // sig = SinOsc.ar(freq:freq, phase:0.0, mul:1.0, add:0.0);
    sig = SinOsc.ar(freq:freq, phase:0.0, mul:1.0, add:0.0);
    //sig = LFTri.ar(freq * [0, 0.1].midiratio);
    sig = sig * env * amp;
    sig = sig ! 2;
    Out.ar(out, sig);
  }).add;

  MIDIdef.noteOn(
    key: \keysNoteOn,
    chan: 0,
    func: {
      |val, num, chan, src|
      [\keysNoteOn, val, num, chan, src].postln;
      ~notes.put(
        num,
        Synth.tail(s, \vco, [
          \freq, num.midicps,
          \gate, 1,
          \amp, val.linexp(0, 127, 0.01, 0.25),
          \lfoBus, ~lfo,
        ]);
      );
    }
  ).permanent_(true);
  MIDIdef.noteOff(
    key: \keysNoteOff,
    chan: 0,
    func: {
      |val, num, chan, src|
      [\keysNoteOff, val, num, chan, src].postln;
      ~notes[num].set(\gate, 0);
      ~notes.put(num, nil);
    }
  ).permanent_(true);

  // knobs for envelope attack/decay, through command buses

  // push synthdef to bus
  // read bus through filter, knobs for cutoff and resonance
)
