public class Sample {
    Panner panner;
    Fader fader;
    "out" => string fadeState;
    1 => int active;
    Chooser chooser;

    // use PainGain's gain by default
    SndBuf sample;
    Pan2 pan;
    Gain out;
    0.5 => float maxGain;

    fun void initialise(string filepath, int loop, float endGain, UGen outputLeft, UGen outputRight ) {
        sample.loop( loop );
        sample.read( filepath );

        endGain => maxGain;
        0 => sample.gain;
        sample => out => pan;
        pan.left => outputLeft; // left
        pan.right => outputRight; // right
        <<< sample.gain >>>;
        spork ~ panner.initialise( pan );

        fadeIn( endGain );

        while ( true ) {
            1::second => now;
        }
    }

    fun dur fadeIn( float gain ) {
        chooser.getDur( 2, 7 ) => dur fadeTime;
        "in" => string fadeState;
        changeFade( fadeState, fadeTime );
        return fadeTime;
    }

    fun void changeFade( string targetState, dur fadeTime ) {
        <<< "targetState", targetState >>>;
        Fader.getTimeIncrement( fadeTime ) => dur timeIncrement;
        Fader.getGainIncrement() => float gainIncrement;
        "in" => string newState;

        if ( targetState == "out" ) {
            -gainIncrement => gainIncrement;
        }

        while( fadeTime > 0::second ) {
            sample.gain() => float currGain;
            currGain + gainIncrement => float newGain;
            newGain => sample.gain;

            timeIncrement -=> fadeTime;
            timeIncrement => now;
        }

        targetState => fadeState;
    }

    fun void setVol( float vol ) {
        // safety!
        if ( vol > 0.8 ) {
            <<< "WARNING VOL OVER MAX THRESHOLD, LIMITING" >>>;
            0.8 => vol;
        }

        vol => sample.gain;
    }

    fun void reverse( dur duration) {
        setRate( -1.0 );
        duration => now;
        setRate( 1.0 );
    }

    fun void setRate( float rate ) {
        sample.rate( rate );
    }

    fun void tearDown() {
        panner.tearDown();
    }
}

