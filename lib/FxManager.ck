public class FxManager {
    Chooser chooser;
    Panner panner;
    3 => int maxConcurrentFx;
    Gain inputGain;
    0.5 => inputGain.gain;
    Pan2 outputPan;
    0.5 => outputPan.gain;

    // spork ~ panner.initialise(outputPan);
    outputPan => dac;

    Fx @ fxChain[ maxConcurrentFx ];
    Fx @ fxBattery[3];

    fun void initialise() {
        new FxDelay @=> fxBattery[0];
        new FxChorus @=> fxBattery[1];
        new FxReverb @=> fxBattery[2];

        fxChainBuild();
    }

    fun void connect( UGen gen ) {
        <<< "begorrah" >>>;
        gen => inputGain;
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
        for ( 0 => int i; i < fxChain.cap(); i++ ) {
            fxChain[ i ] @=> Fx fx;

            spork ~ fx.initialise();

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
        }
    }
}
