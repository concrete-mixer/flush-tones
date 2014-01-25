public class Sample {
    Fader fader;
    "out" => string fadeState;
    1 => int active;
    Chooser chooser;

    // use PainGain's gain by default
    SndBuf buf;
    Pan2 pan;
    0.5 => float maxGain;

    fun void initialise(string filepath, int loop, float endGain, UGen outputLeft, UGen outputRight ) {
        buf.read( filepath );
        buf.loop( loop );
        filepath => buf.read;
        endGain => maxGain;
        buf => pan;
        pan.left => outputLeft; // left
        pan.right => outputRight; // right

        if ( loop ) {
            Panner panner;
            spork ~ panner.initialise( pan );
            // 0 => buf.gain;
            // fadeIn( endGain );

            spork ~ reverseSchedule();
        }
        else {
            chooser.getFloat( -1.0, 1.0 ) => pan.pan;
            endGain => buf.gain;
            <<< "Gain", buf.gain() >>>;
            buf.length() => now;
            buf =< pan;
            pan.left =< outputLeft;
            pan.right =< outputRight;
            0 => active;
        }
    }

    fun void reverseSchedule() {
        while ( true ) {
            chooser.getDur( 3, 8 ) => dur duration;
            if ( chooser.takeAction( 3 ) ) {
                reverse( duration );
            }
            else {
                duration => now;
            }
        }
    }

    fun void reverse( dur duration) {
        setRate( -1.0 );
        duration => now;
        setRate( 1.0 );
    }

    fun void setRate( float rate ) {
        buf.rate( rate );
    }

    fun void tearDown() {
    }
}

