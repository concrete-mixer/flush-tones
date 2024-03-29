public class Panner extends LFO {
    10 => int actionDenominator;
    5.0 => float waitMin;
    15 => float waitMax;
    [ "fixed point", "LFO" ] @=> string panTypes[];
    1 => int active;

    Pan2 pan;

    fun void initialise( Pan2 inputPan ) {
        inputPan @=> pan;
        setType();
    }

    fun void setType() {
        chooser.getInt( 0, panTypes.cap() - 1 ) => int i;
        panTypes[ i ] => string panType;
        <<< "pan type", panType >>>;

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

    fun string getOscType() {
        [ "sine", "square" ] @=> string oscTypes[];

        return oscTypes[ chooser.getInt( 0, oscTypes.cap() - 1 ) ];
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

    // set LFO type and generate LFO frequencies and amounts for panning
    fun void makeLFOPan() {
        getOscType() => string oscType;
        float freq;
        float amount;

        // sine pans work better slower, while square wave pans work
        // better faster but shallower, so we need to tweak a bit
        if ( oscType == "sine" ) {
            chooser.getFloat( 0.05, 0.25 ) => freq;
            chooser.getFloat( 0.5, 1.0 ) => amount;
        }

        if ( oscType == "square" ) {
            chooser.getFloat( 0.5, 5 ) => freq;
            chooser.getFloat( 0.2, 0.5 ) => amount;
        }
        <<< "PanGain running changePan(): freq", freq, "amount", amount, "duration", "oscillator type", oscType >>>;
        changePan( freq, amount, oscType );
    }

    fun void tearDown() {
        0 => active;
    }
}

