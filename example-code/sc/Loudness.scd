

code::
//create a monitoring bus for the descriptors
b = Bus.new(\control,0,2);

//create a monitoring window for the values
(
w = Window("Loudness Monitor", Rect(10, 10, 220, 65)).front;

c = Array.fill(2, {arg i; StaticText(w, Rect(10, i * 25 + 10, 135, 20)).background_(Color.grey(0.7)).align_(\right)});
c[0].string = ("Loudness: ");
c[1].string = ("Peak: ");

a = Array.fill(2, {arg i;
	StaticText(w, Rect(150, i * 25 + 10, 60, 20)).background_(Color.grey(0.7)).align_(\center);
});
)

//routine to update the parameters
(
r = Routine {
	{
		b.get({ arg val;
			{
				if(w.isClosed.not) {
					val.do({arg item,index;
						a[index].string = item.round(0.01)})
				}
			}.defer
		});
		0.1.wait;
	}.loop
}.play
)

//basic test, with default values
(
x = {var source = PinkNoise.ar(0.25);
	Out.kr(b, FluidLoudness.kr(source));
	source.dup;
}.play;
)

//free this
x.free

//the EBU standard specifies that the window should be 400ms long, and update every 100ms, for instantaneous loudness. At SR=44100, this means the following settings. Various test signals are loaded.
(
x = {
	arg freq=220, type = 1, noise = 0;
	var source = PinkNoise.ar(noise) + Select.ar(type,[DC.ar(),SinOsc.ar(freq,mul:0.1), VarSaw.ar(freq,mul:0.1), Saw.ar(freq,0.1), Pulse.ar(freq,mul:0.1)]);
	Out.kr(b, FluidLoudness.kr(source,windowSize:17640,hopSize:4410,maxwindowSize:17640));
	source.dup;
}.play;
)
// change the various frequencies to see the impact of the filter for the loudness. The TruePeak is steady.
x.set(\freq, 440)
x.set(\freq, 110)
x.set(\freq, 55)
x.set(\freq, 3000)
x.set(\freq, 9000)

// adding harmonics, by changing to triangle (2), saw (3) or square (4) shows that spectral algo are more resilient when signal are richer
x.set(\type, 2)
x.set(\type, 3)
x.set(\type, 4)

// adding noise shows its impact on loudness
x.set(\noise, 0.25)

// and removing the oscilator
x.set(\type, 0)

// and measuring silence
x.set(\noise, 0)
::