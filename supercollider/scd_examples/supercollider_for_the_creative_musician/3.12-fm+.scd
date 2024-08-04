(
  {
    var sig, mod1, mod2;
    mod2 = SinOsc.ar(freq:0.2, phase:0.0, mul:450, add:0.0);
    mod1 = SinOsc.ar(freq:500+mod2, phase:0.0, mul:800, add:0.0);
    sig = SinOsc.ar(freq:1000+mod1, phase:0.0, mul:1.0, add:0.0);
    sig = sig * 0.2 ! 2;
  }.play;
)
(
  {
    var sig, mod1, mod2;
    mod2 = SinOsc.ar(freq:0.2, phase:0.0, mul:450, add:0.0);
    mod1 = SinOsc.ar(freq:500, phase:0.0, mul:800, add:0.0);
    sig = SinOsc.ar(freq:1000 + mod1 + mod2, phase:0.0, mul:1.0, add:0.0);
    sig = sig * 0.2 ! 2;
  }.play;
)
