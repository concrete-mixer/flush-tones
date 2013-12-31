public class Panner extends LFO {
    Chooser c;
    10 => int actionDenominator;
    5.0 => float waitMin;
    15 => float waitMax;
    Pan2 panL, panR;

    panL => dac;
    panR => dac;

    fun void initialise( SndBuf buf1 ) {
        buf1 => panL;
        buf1 => panR;
    }

    fun void initialise( SndBuf buf1, SndBuf buf2 ) {
        buf1 => panL;
        buf2 => panR;
    }

    // the following should be overwritten by mono and stereo child classes
    fun void resetPan() {
        -1.0 => panL.pan;
        1.0 => panL.pan;
    }

    fun void setPan( float position ) {
        position => panL.pan;
        position => panR.pan;
    }

    fun void changePan( float freq, float amount, dur panDuration, string oscType ) {
        while ( panDuration > 0::second ) {
            setPan( osc( freq, amount, oscType ) );
            1 :: ms -=> panDuration;
            1 :: ms => now;
        }

        resetPan();
    }

    fun void makePan() {
        // need the 
        c.getFloat( 0.05, 5 ) => float freq;
        c.getFloat( 0, 1.0 ) => float amount;
        c.getDur( 5, 60 ) => dur panDuration;
        getOscType() => string oscType;
        <<< "PanGain running changePan(): freq ", freq, " amount ", amount, " duration ", panDuration, " oscillator type ", oscType >>>;

        changePan( freq, amount, panDuration, oscType );
    }
}

