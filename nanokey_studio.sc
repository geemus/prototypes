(
  s.boot;

  ~notes = Array.newClear(indexedSize:128);

  SynthDef(\tone, {
    arg buf = 0, gate = 1, amp = 0.2,
    freq = 220, rel = 0.3, out = 0;
    var sig, env;
    env = Env.asr(0.002, 1, rel).kr(2, gate);
    sig = LFTri.ar(freq * [0, 0.1].midiratio);
    sig = sig * env * amp;
    Out.ar(out, sig);
  }).add;

  MIDIIn.connectAll(verbose:true);

  MIDIdef.noteOn(key: \on, func: {
    |val, num, chan, src|
    [\on, val, num, chan, src].postln;
    [\tone, \freq, num.midicps, \gate, 1, \amp, val.linexp(0, 127, 0.01, 0.25)].postln;
    ~notes.put(
      num,
      Synth(\tone, [
        \freq, num.midicps,
        \gate, 1,
        \amp, val.linexp(0, 127, 0.01, 0.25)
      ]);
    );
  }).permanent_(true);

  MIDIdef.noteOff(key: \off, func: {
    |val, num, chan, src|
    [\off, val, num, chan, src].postln;
    ~notes[num].set(\gate, 0);
    ~notes.put(num, nil);
  }).permanent_(true);
  );
);
