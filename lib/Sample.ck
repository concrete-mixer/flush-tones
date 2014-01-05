public class Sample {
    Panner panner;
    Fader fader;
    "out" => string fadeState;
    1 => int active;

    // use PainGain's gain by default
    SndBuf buf1, buf2;
    Pan2 panL, panR;
    1 => int channelCount;

    fun void initialise(string filepath, int loop) {
        // here we need to work out number of channels and whether
        // sndbuf should be mono or stereo. See
        // https://lists.cs.princeton.edu/pipermail/chuck-users/2010-November/005864.html

        buf1.read(filepath);
        0 => buf1.gain;
        buf1 => panL => dac;

        buf1.channels() => channelCount;

        // if channel number is 1, easy, just plug bufM to PanGain
        if ( channelCount == 1 ) {
            loop => buf1.loop;
        }

        // if two channels, we need to bring two SndBufs into play and route
        // one each to a pan
        if ( channelCount == 2 ) {
            // bring in another buf
            buf2.read(filepath);
            0 => buf2.gain;
            buf2 => panR => dac;

            // set buf1 to use left channel and buf2 to use right
            0 => buf1.channel;
            1 => buf2.channel;

            loop => buf1.loop;
            loop => buf2.loop;
        }
        else {
            buf1 => panR => dac;
        }

        // set pan model
        spork ~ panner.initialise( panL, panR );
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
            buf1.gain() => float currGain;
            currGain + gainIncrement => float newGain;
            newGain => buf1.gain;

            if ( channelCount == 2 ) {
                newGain => buf2.gain;
            }

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

        vol => buf1.gain;

        if ( channelCount == 2 ) {
            vol => buf2.gain;
        }
    }

    fun void connect( Gain inputL, Gain inputR ) {
        <<< "Sample.connect(): running" >>>;
        panL =< dac;
        panL => inputL;

        if ( channelCount == 2 ) {
            panR =< dac;
            panR => inputR;
        }
        else {
            panR => inputR;
            panR =< dac;
        }
    }

    fun void disconnect( Gain outputL, Gain outputR ) {
        <<< "disconnecting" >>>;
        panL =< outputL;
        panL => dac;

        if ( channelCount == 2 ) {
            panR =< outputR;
            panR => dac;
        }
        else {
            panR =< outputR;
            panR => dac;
        }
    }

    fun void reverse( dur duration) {
        setRate( -1.0 );
        duration => now;
        setRate( 1.0 );
    }

    fun void setRate( float rate ) {
        buf1.rate( rate );

        if ( channelCount == 2 ) {
            buf2.rate( rate );
        }
    }

    fun int getSampleCount() {
        return buf1.samples();
    }

    fun void tearDown() {
        panner.tearDown();
    }
}

