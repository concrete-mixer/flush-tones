public class Sample {
    Fader fader;
    "out" => string fadeState;
    1 => int active;
    Chooser chooser;
    string filepath;

    // use PainGain's gain by default
    SndBuf buf;
    Pan2 pan;
    0.5 => float maxGain;
    UGen outLeft, outRight;

    fun void initialise(string filepathIn, int loop, float endGain, UGen outputLeft, UGen outputRight ) {
        filepathIn => filepath;
        buf.read( filepath );
        buf.loop( loop );
        filepath => buf.read;
        endGain => maxGain;
        buf => pan;

        outputLeft @=> outLeft;
        outputRight @=> outRight;
        pan.left => outputLeft; // left
        pan.right => outputRight; // right

        if ( loop ) {
            Panner panner;
            spork ~ panner.initialise( pan );
            reverseSchedule();
        }
        else {
            if ( chooser.getInt( 1, 6 ) == 1 ) {
                <<< "REVERSING ONE SHOT" >>>;
                setRate( -1.0 );
            }

            chooser.getFloat( -1.0, 1.0 ) => pan.pan;
            endGain => buf.gain;
            buf.length() => now;
            buf =< pan;
            pan.left =< outputLeft;
            pan.right =< outputRight;
            0 => active;
        }
    }

    fun void reverseSchedule() {
        while ( active ) {
            chooser.getDur( 3, 8 ) => dur duration;

            if ( chooser.takeAction( 8 ) ) {
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
        0 => active;
        fader.fadeOut( 2::second, buf );
        buf =< pan;
        pan.left =< outLeft;
        pan.right =< outRight;
    }

    // API call to give Sample option of killing or lowering
    // its dry output
    // useful for providing variation when using fx chains
    fun void setMixChoice() {
        chooser.getInt( 0, 8 ) => int mixChoice;

        // if mixChoice is 0, kill dry output
        // if 1-6, keep dry volume normal
        // if 7-8, halve volume
        if ( !mixChoice ) {
            // set sample dry out to 0
            0 => setMix;
        }
        else if ( mixChoice > 6 ) {
            // halve dry gain
            buf.gain() / 2 => setMix;
        }
    }

    fun void setMix( float gain ) {
        0 => pan.gain;
    }
}

