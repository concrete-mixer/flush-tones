public class Sample {
    Panner panner;
    Fader fader;
    "out" => string fadeState;
    1 => int active;

    // use PainGain's gain by default
    WvIn sample;
    Pan2 pan;
    Gain out;
    1 => int channelCount;
    0.8 => float maxGain;

    fun void initialise(string filepath, int loop, float vol ) {
        if ( loop ) {
            WaveLoop wave;
            wave.path( filepath );
            wave @=> sample;
        }
        else {
            sample.path( filepath );
        }

        vol => maxGain;
        vol => sample.gain;
        sample => out => pan => dac;
        <<< sample.gain >>>;
        spork ~ panner.initialise( pan );

        while ( true ) {
            1::second => now;
        }
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

