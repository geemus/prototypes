(
  {
    var sig, mod, modHz;
    modHz = XLine.kr(start:1, end:150, dur:10, mul:1.0, add:0.0, doneAction:0);
    mod = SinOsc.ar(freq:modHz, phase:0.0, mul:300, add:0.0);
    sig = SinOsc.ar(freq:750+mod, phase:0.0, mul:1.0, add:0.0);
    sig = sig * 0.2 ! 2;
  }.play();
)
