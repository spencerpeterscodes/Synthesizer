import("stdfaust.lib");
declare options "[midi:on]";

//MIDI inputs
freq = hslider("freq", 100, 20, 4000, 1);
gain = nentry("gain", 0.1, 0, 1, 0.01) : si.smoo;
gate = checkbox("gate");

//Example LFO
// lfo_freq = hslider("lfo", 1, 0.1, 20, 0.1);
// lfo1 = os.lf_saw(lfo_freq);
// lfo_on = checkbox("lfo_to_filter");
//normFreq = hslider("Filt.freq.", 0.1, 0., .7, .01) + lfo1 * 0.2 * lfo_on;
//analog_filt3 = ve.oberheimLPF(normFreq, Q);
//Q = hslider("Q", 1, 0.1, 10, 0.1);

//Waveform Gain
gsaw = hslider("saw", 0.1, 0.0, 0.95, 0.01);
gsqu = hslider("square", 0.1, 0.0, 0.95, 0.01);
gtri = hslider("triangle", 0.1, 0.0, 0.95, 0.01);

//Waveform ADSR
adsr = hgroup("AMP EG", en.adsr(at, dt, sl, rt, gate))
with{
    at = hslider("[0]Attack[style:knob]", 1, 0.01, 5, 0.01) : si.smoo;
    dt = hslider("[1]Decay[style:knob]", 0.5, 0, 1, 0.1) : si.smoo;
    sl = hslider("[2]Sustain[style:knob]", 0.5, 0.1, 1, 0.1) : si.smoo;
    rt = hslider("[3]Release[style:knob] [unit:s]", 5, 0.5, 10, 0.5) : si.smoo;
};

//Mixer 
//lfoSq = os.lf_squarewave(lfoSq_freq);

lfoSquare = hgroup("Square LFO", os.lf_squarewave(lfoSq_freq) * lfoAmm * lfoSwitch)
with{
    lfoSq_freq = hslider("LFO Rate", 1, 0.1, 20, 0.1);
    lfoAmm = hslider("Amount [style:knob]", 0.15, 0.01, 0.2, 0.01);
    lfoSwitch = checkbox("LFO2Filt");

};
//  + lfo1 * 0.2 * lfo_on  attaches to normFreq between the ) and the : in order to connect the LFO to the frequency cut off


Q = hslider("Q",1,0.5,10,0.01) : si.smoo;
normFreq = hslider("Filter Freq", 0.5, 0, 0.80, 0.01) + lfoSquare : si.smoo;
filter = ve.korg35LPF(normFreq, Q);

//ve.korg35HPF(normFreq, Q);
// Modulation Wheel is controller number 1
// Pitch Bend has a different 

//Control 
// First 4 tell you the type of command
// the last 4 bits encode the channel 
// Pitch bend has its own message 

saw = os.sawtooth(freq) * 0.33;
squ = os.square(freq) * 0.33;
tri = os.triangle(freq) * 0.33;

// brightLfoslider = hslider("lfo_Bright", 1.25, 1, 20, 0.125) : si.smoo;
// brightLfo = os.lf_saw(brightLfoslider);

bright = hslider("Brightness", 0, 0, 0.5, 0.01) : si.smoo;
casio = os.CZsquare(saw, bright);
// halfSine = os.CZhalfSine(saw, bright) * 0.1;


//Filters that have a resonance, will increase the gain and make it stronger,
// Filters treating frequencies will reduce the signal on the other
reverb = re.zita_rev1_stereo(1,100,200, 1, 2, ma.SR);
verbOn = checkbox("Reverb Off");
//<: ba.bypass2(verbOn, reverb) 
process = (saw * gsaw + squ * gsqu + tri * gtri) : filter * adsr <: _,_;

// reverb = hgroup("Reverb",re.zita_rev1_stereo(rdel,f1,f2,t60dc,t60m,fsmax)) 
// with{
//     rdel = 10;
//     f1 = hslider("Frequency 1", 100, 20, 500, 0.1);
//     f2 = hslider("Frequency 2", 500, 500, 1000, 0.1);
//     t60dc = 1;
//     t60m = 2;
//     fsmax = ma.SR;


// };
// verbOn = checkbox("Reverb Off") :si.smoo;


//process = casio * gain : filter * adsr <: ba.bypass2(verbOn, reverb) : _,_;
