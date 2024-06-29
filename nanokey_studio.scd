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
  SynthDef(\tone, {
    arg buf = 0, gate = 1, amp = 0.2,
    freq = 220, rel = 0.3, out = 0;
    var sig, env;
    env = Env.asr(0.002, 1, rel).kr(2, gate);
    sig = LFTri.ar(freq * [0, 0.1].midiratio);
    sig = sig * env * amp;
    Out.ar(out, sig);
  }).add;

  // touchpad pitch/mod x
  MIDIdef.bend(
    key: \bend,
    chan: 0,
    func: {
      |val, num, chan, src|
      [\bend, val, num, chan, src].postln;
    }
  ).permanent_(true);

  // 1 touchpad pitch/mod y
  // 16 touchpad X-Y X, 17 touchpad X-Y Y
  MIDIdef.cc(
    key: \tp,
    chan: 0,
    ccNum: #[1,16,17],
    func: {
      |val, num, chan, src|
      [\tp, val, num, chan, src].postln;
    }
  ).permanent_(true);

  // 20-27 scene 1 knobs
  // 28-36 scene 2 knobs
  // 37-44 scene 3 knobs
  // 45-52 scene 4 knobs
  // 53-60 scene 5 knobs
  // 70-77 scene 6 knobs
  // 78-86 scene 7 knobs
  // 87-94 scene 8 knobs
  MIDIdef.cc(
    key: \knob,
    chan: 0,
    ccNum: #[20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,
    70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94],
    func: {
      |val, num, chan, src|
      [\knob, val, num, chan, src].postln;
    }
  ).permanent_(true);

  MIDIdef.noteOn(
    key: \keysNoteOn,
    chan: 0,
    func: {
      |val, num, chan, src|
      [\keysNoteOn, val, num, chan, src].postln;
      ~notes.put(
        num,
        Synth(\tone, [
          \freq, num.midicps,
          \gate, 1,
          \amp, val.linexp(0, 127, 0.01, 0.25)
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

  MIDIdef.noteOn(
    key: \padsNoteOn,
    chan: 1,
    func: {
      |val, num, chan, src|
      [\padsNoteOn, val, num, chan, src].postln;
    }
  ).permanent_(true);

  MIDIdef.noteOff(
    key: \padsNoteOff,
    chan: 1,
    func: {
      |val, num, chan, src|
      [\padsNoteOff, val, num, chan, src].postln;
    }
  ).permanent_(true);
)
