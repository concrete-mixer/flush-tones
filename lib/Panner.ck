public class Panner extends LFO {
    Chooser chooser;
    10 => int actionDenominator;
    5.0 => float waitMin;
    15 => float waitMax;
    [ "normal", "reverse", "mono", "fixed point", "scramble", "LFO" ] @=> string panTypes[];
    1 => int active;

    Pan2 pan;

    fun void initialise( Pan2 inputPan ) {
        return;
        inputPan @=> pan;
        setType();
    }

    fun void setType() {
        chooser.getInt( 0, panTypes.cap() - 1 ) => int i;
        // panTypes[ i ] => string panType;
        panTypes[ 5 ] => string panType;
        <<< "pan type", panType >>>;
        // this follows normal two channel stereo: all of one channel
        // to left speaker, and all of the other to right speaker
        if ( panType == "mono" ) {
            setPan( pan, 0 );
        }

        // this sets the pan to an arbitary position between left and right
        if ( panType == "fixed point" ) {
            chooser.getFloat( -1.0, 1.0 ) => float position;
            setPan( pan, position );
        }

        // finally, apply dynamic pan based on LFO
        if ( panType == "LFO" ) {
            makeLFOPan();
        }
    }

    fun void setPan( Pan2 pan, float position ) {
        position => pan.pan;
    }

    fun void changePan( float freq, float amount, string oscType ) {
        while ( active ) {
            osc( freq, amount, oscType ) => float position;
            setPan( pan, position );
            100 :: ms => now;
        }
    }

    fun void makeLFOPan() {
        chooser.getFloat( 0.05, 5 ) => float freq;
        chooser.getFloat( 0.2, 1.0 ) => float amount;
        getOscType() => string oscType;
        <<< "PanGain running changePan(): freq", freq, "amount", amount, "duration", "oscillator type", oscType >>>;
        changePan( freq, amount, oscType );
    }

    fun void tearDown() {
        0 => active;
    }
}

