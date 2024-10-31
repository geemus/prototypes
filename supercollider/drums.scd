(
  s.waitForBoot({
    s.sync;
    StageLimiter.activate;

    // https://blog.rumblesan.com/post/53271713518/drum-sounds-in-supercollider-part-1
    SynthDef.new(\kickdrum, {
        var subosc, subenv, suboutput, clickosc, clickenv, clickoutput;

        subosc = {SinOsc.ar(55)};
        subenv = Line.ar(start:1.0, end:0.0, dur:0.3, mul:1.0, add:0.0, doneAction:2);

        clickosc = {LPF.ar(WhiteNoise.ar(1),1500)};
        clickenv = {Line.ar(1.0, 0, 0.02)};

        suboutput = (subosc * subenv);
        clickoutput = (clickosc * clickenv);

        Out.ar(0,
            Pan2.ar(suboutput + clickoutput, 0)
        )
    }).add;

    SynthDef(\snaredrum, {
      var drumosc, filterenv, drumoutput, volenv, snaposc, snapenv, fulloutput;

      filterenv = {Line.ar(1, 0, 0.2, doneAction: 0)};
      volenv = {Line.ar(1, 0, 0.6, doneAction: 2)};

      drumosc = {Pulse.ar(100)};
      drumoutput = {LPF.ar(drumosc,(filterenv *1000) + 30)};

      snaposc = {BPF.ar(HPF.ar(WhiteNoise.ar(1),500),1500)};
      snapenv = {Line.ar(1, 0, 0.2, doneAction: 0)};

      fulloutput = (drumoutput * volenv) + (snaposc * snapenv);

      Out.ar(0,
        Pan2.ar(fulloutput, 0)
      )
    }).add;

    // stretch = 60 (seconds per minute) / beats per minute * beats per bar
    // stretch = 60 (seconds per minute) / beats per minute * beats per bar / subdivision

    Pdef.new(\kick,
      Pbind(
        \instrument, \kickdrum,
        \dur, Pseq([1], inf),
        \stretch, 0.5
      )
    );

    Pdef.new(\snare,
      Pbind(
        \instrument, \snaredrum,
        \dur, Pseq([Rest(1), 1, Rest(1), 1], inf),
        \stretch, 0.5
      )
    );
  });
)

Ndef.new(\kick, Pdef(\kick));
Ndef(\kick).clear;

Ndef.new(\snare, Pdef(\snare));
Ndef(\snare).clear;

(
  Ndef.new(\kit,
    Ppar([
      Pdef(\kick),
      Pdef(\snare)
    ])
  );
)
Ndef(\kit).clear;
