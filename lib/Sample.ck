public class Sample {
    Panner panner;
    Fader fader;
    "out" => string fadeState;
    1 => int active;

    // use PainGain's gain by default
    SndBuf buf;
    Pan2 pan;
    1 => int channelCount;

    fun void initialise(string filepath, int loop) {
        // here we need to work out number of channels and whether
        // sndbuf should be mono or stereo. See
        // https://lists.cs.princeton.edu/pipermail/chuck-users/2010-November/005864.html

        buf.read(filepath);
        0 => buf.gain;
        buf;
        pan => dac;
        // if channel number is 1, easy, just plug bufM to PanGain
        if ( channelCount == 1 ) {
            loop => buf.loop;
        }

        // if two channels, we need to bring two SndBufs into play and route
        // one each to a pan

        spork ~ panner.initialise( pan );
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
            buf.gain() => float currGain;
            currGain + gainIncrement => float newGain;
            newGain => buf.gain;

            timeIncrement -=> fadeTime;
            timeIncrement => now;
        }

        targetState => fadeState;
        <<< "fadeState", fadeState >>>;
    }

    fun void setVol( float vol ) {
        // safety!
        if ( vol > 0.8 ) {
            <<< "WARNING VOL OVER MAX THRESHOLD, LIMITING" >>>;
            0.8 => vol;
        }

        vol => buf.gain;
    }

    fun void connect( Gain input ) {
        <<< "Sample.connect(): running" >>>;
        buf => input;
    }

    fun void disconnect( Gain output ) {
        <<< "disconnecting" >>>;
        pan =< output;
    }

    fun void reverse( dur duration) {
        setRate( -1.0 );
        duration => now;
        setRate( 1.0 );
    }

    fun void setRate( float rate ) {
        buf.rate( rate );
    }

    fun int getSampleCount() {
        return buf.samples();
    }

    fun void tearDown() {
        panner.tearDown();
    }
}

