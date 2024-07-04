(
  s.boot;
  {
    var sig, mod;
    mod = SinOsc.ar(freq:4, phase:3pi/2, mul:1.0, add:0.0).range(0, 3000);
    sig = Pulse.ar([90,91]);
    sig = LPF.ar(in:sig, freq:200 + mod, mul:1.0, add:0.0);
    sig = sig * 0.1;
  }.play
)
