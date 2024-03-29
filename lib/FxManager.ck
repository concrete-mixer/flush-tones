public class FxManager {
    Chooser chooser;
    Panner panner;
    Fader fader;

    2 => int maxConcurrentFx;
    Gain inputGain;
    0.7 => inputGain.gain;
    Pan2 outputPan;
    0.7 => outputPan.gain;

    // spork ~ panner.initialise(outputPan);
    Fx @ fxChain[ maxConcurrentFx ];
    Fx @ fxBattery[6];

    new FxDelay @=> fxBattery[0];
    new FxFilter @=> fxBattery[1];
    new FxChorus @=> fxBattery[2];
    new FxReverb @=> fxBattery[3];
    new FxFlanger @=> fxBattery[4];
    new FxDelayVariable @=> fxBattery[5];

    UGen outLeft, outRight;

    fun void initialise( UGen outputL, UGen outputR ) {
        outputL @=> outLeft;
        outputR @=> outRight;

        // Fx chain is mono, let's make a little cheap stereo
        Delay delay;
        chooser.getDur( 0.001, 0.005 ) => delay.delay;

        // should left side be delayed or right?
        if ( chooser.getInt( 0, 1 ) ) {
            <<< "RIGHT" >>>;
            outputPan.left => outLeft;
            outputPan.right => delay => outRight;
        }
        else {
            <<< "LEFT" >>>;
            outputPan.left => delay => outLeft;
            outputPan.right => outRight;
        }

        fxChainBuild();
    }

    fun void connect( UGen gen ) {
        gen => inputGain;
    }

    fun void disconnect( UGen gen ) {
        gen =< inputGain;
    }

    fun void fxChainBuild() {
        0 => int i;

        while( i < maxConcurrentFx ) {
            chooser.getInt( 0, fxBattery.cap() - 1 ) => int j;

            // need to check if effect for j is already in fxChain
            if ( effectNotAlreadyPresent( fxBattery[ j ] ) ) {
                fxBattery[ j ] @=> fxChain[ i ];
                i++;
            }
        }

        // fxChain now set up, so wire everything up
        fxChainFx();
    }

    fun int effectNotAlreadyPresent( Fx fx ) {
        for ( 0 => int j; j < maxConcurrentFx; j++ ) {
            if ( fxChain[ j ] != NULL && fxChain[ j ].idString() == fx.idString() ) {
                return 0;
            }
        }

        return 1;
    }

    fun void fxChainFx() {
        <<< "FXCHAIN:" >>>;
        for ( 0 => int i; i < fxChain.cap(); i++ ) {
            fxChain[ i ] @=> Fx fx;

            spork ~ fx.initialise();
            <<< i, fx.idString() >>>;
            if ( i == 0 ) {
                inputGain => fx.input;
            }
            else {
                fxChain[ i - 1 ] @=> Fx upstreamFx;
                upstreamFx.output => fx.input;
            }

            if ( i == fxChain.cap() - 1 ) {
                fx.output => outputPan;
            }
            else {
                <<< "=>" >>>;
            }
        }

        <<< "END OF FXCHAIN DEBUG" >>>;
    }

    fun void tearDown() {
        for ( 0 => int i; i < fxChain.cap(); i++ ) {
            fxChain[ i ] @=> Fx fx;
            if ( i == 0 ) {
                inputGain =< fx.input;
            }
            else {
                fxChain[ i - 1 ] @=> Fx upstreamFx;
                upstreamFx.output =< fx.input;
            }

            if ( i == fxChain.cap() - 1 ) {
                fx.output =< outputPan;
            }

        }

        Fx fxChainNew[ maxConcurrentFx ];
        fxChainNew @=> fxChain;

        <<< "disengaging outputPan from dynos">>>;
        outputPan.left =< outLeft;
        outputPan.right =< outRight;
    }
}
