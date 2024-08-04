(
  s.waitForBoot({
    s.sync;
    StageLimiter.activate;

    SynthDef.new(\sine, {
      arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
      var sig, env;
      sig = SinOsc.ar(freq);
      env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
      sig = Pan2.ar(sig, pan, amp);
      sig = sig * env;
      Out.ar(0, sig);
    }).add;
    SynthDef.new(\square, {
      arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
      var sig, env;
      //sig = SinOsc.ar(freq);
      sig = LFPulse.ar(freq:freq);
      env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
      sig = Pan2.ar(sig, pan, amp);
      sig = sig * env;
      Out.ar(0, sig);
    }).add;

    // stretch = 60 (seconds per minute) / beats per minute * beats per bar
    // stretch = 60 (seconds per minute) / beats per minute * beats per bar / subdivision

    Pdef.new(\subs_high,
      Pbind(
        \instrument, \sine,
        \dur, Pseq(
          [
            Pseq([1, 2, 2], 3),
            Pseq([Rest(5)], 1),
          ],
          inf),
        \midinote, Pxrand([60, 60, 63, 65, 72], inf),
        \stretch, 0.1171875,
      )
    );
    Pdef.new(\subs_low,
      Pbind(
        \instrument, \square,
        \dur, Pseq([2, Rest(6)], inf),
        \midinote, Pxrand([48, 48, 51, 53, 36], inf),
        \stretch, 0.1171875,
      )
    );


    Pdef.new(\high,
      Pbind(
        \instrument, \sine,
        \dur, Pseq([1/8, 1/16, 1/16, 1/4], inf),
        \midinote, Pxrand([60, 60, 63, 65, 72], inf),
        \stretch, 1.875,
      )
    );
    Pdef.new(\low,
      Pbind(
        \instrument, \square,
        \dur, Pseq([1/6, 1/12, 1/12, 1/3], inf),
        \midinote, Pxrand([48, 48, 51, 53, 36], inf),
        \stretch, 1.875,
      )
    );

    Pdef.new(\rests4,
      Pbind(
        \instrument, \sine,
        \dur, Pseq([
          1/8, Rest(1/8), Rest(1/8), 1/8,
          Rest(1/8), 1/8, Rest(1/8), 1/8,
          1/8, 1/8, 1/8, 1/8
        ], inf),
        \midinote, Prand([60, 63, 65, 72], inf),
        \stretch, 1.875,
      )
    );
    Pdef.new(\rests3,
      Pbind(
        \instrument, \square,
        \dur, Pseq([
          1/6, 1/6, Rest(1/6),
          Rest(1/6), 1/6, 1/6,
          1/6, 1/6, 1/6,
          Rest(1/6), 1/6, 1/6,
        ], inf),
        \midinote, Prand([48, 51, 53, 36], inf),
        \stretch, 1.875,
      )
    );
  });
)

Ndef.new(\subs_high, Pdef(\subs_high));
Ndef(\subs_high).clear;

Ndef.new(\subs_low, Pdef(\subs_low));
Ndef(\subs_low).clear;

Ndef.new(\high, Pdef(\high));
Ndef(\high).clear;

Ndef.new(\low, Pdef(\low));
Ndef(\low).clear;

Ndef.new(\rests4, Pdef(\rests4));
Ndef(\rests4).clear;

Ndef.new(\rests3, Pdef(\rests3));
Ndef(\rests3).clear;

(
  Ndef.new(\ppar_subs,
    Ppar([
      Pdef(\subs_high),
      Pdef(\subs_low)
    ])
  );
)
Ndef(\ppar_subs).clear;

(
  Ndef.new(\ppar,
    Ppar([
      Pdef(\high),
      Pdef(\low)
    ])
  );
)
Ndef(\ppar).clear;

(
  Ndef.new(\ppar_rests,
    Ppar([
      Pdef(\rests4),
      Pdef(\rests3)
    ])
  );
)
Ndef(\ppar_rests).clear;
