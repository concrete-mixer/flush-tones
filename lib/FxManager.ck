public class FxManager {
    Chooser chooser;
    2 => int maxConcurrentFx;
    Sample sample;

    Fx @ fxChain[ maxConcurrentFx ];
    Fx @ fxBattery[3];

    new FxDelay @=> fxBattery[0];
    new FxChorus @=> fxBattery[1];
    new FxReverb @=> fxBattery[2];

    fun void initialise( Sample inputSample ) {
        inputSample @=> sample;
    }

    fun void addFx() {
        // <<< "FxManager.addFx" >>>;
        chooser.getInt( 0, fxBattery.cap() - 1 ) => int i;
        // 0 => int i;
        // delay @=> fxBattery[0];
        // Fx delay;
        // fxBattery[i] @=> delay;
        // <<< delay.idString() >>>;
        // spork ~ delay.initialise();
        // delay.outputL => dac.left;
        // delay.outputR => dac.right;
        // sample.connect( delay.inputL, delay.inputR );
        // 10::second => now;
        // sample.disconnect( delay.outputL, delay.outputR );
        // delay.tearDown();
        // <<< "fxBattery execution", i, fxBattery[i].idString() >>>;
        addToCurrentFx( fxBattery[i] );
    }

    fun void removeFx() {
        getCurrentFxCount() => int fxChainCount;
        <<< "FxManager.removeFX() fxChainCount:", fxChainCount >>>;

        if ( fxChainCount ) {
            chooser.getInt( 0, fxChainCount - 1 ) => int i;
            // we can assume that if we have any items we should get rid
            // of the first one (fifo)
            // <<< "FxManager.removeFx(): removing", fxChain[i].idString() >>>;
            removeFromCurrentFx( i );
        }
        else {
            <<< "FxManager.removeFX() nothing to remove" >>>;
        }
    }

    fun int getCurrentFxCount() {
        0 => int fxChainCount;

        for( 0 => int i; i < fxChain.cap(); i++ ) {
            if ( fxChain[i] != NULL ) {
                <<< i, "getCurrentFxCount: we have ", fxChain[i].idString() >>>;
                fxChainCount++;
            }
        }

        // <<< "fxChainCount found:", fxChainCount >>>;
        return fxChainCount;
    }

    fun void addToCurrentFx( Fx fx ) {
        for( 0 => int i; i < fxChain.cap(); i++ ) {
            if ( fxChain[i] == NULL ) {
                // <<< "FxManager.addToCurrentFx: inserting", fx.idString() >>>;
                fx @=> fxChain[i];
                addToChain( i, fx );
                return;
            }
            else if ( fxChain[i].idString() == fx.idString() ) {
                // <<< "Effect already in use, not applying" >>>;
                return;
            }
        }
    }

    /*
        Idenitfying an item to be removed from fxChain,
        we copy the rest of the chain to a new array
        and then replace the original way

        This seems a bit primitive but this may more how things
        are done in C/C++ land

        In any event I haven't found a better way to do this
        Perl grep would be handy about now...
    */
    fun void removeFromCurrentFx( int i ) {
        <<< "removeFromCurrentFx" >>>;
        <<< "   i: ", i >>>;
        Fx @ newFxChain[ maxConcurrentFx ];
        0 => int j;
        fxChain[ i ] @=> Fx fx;

        for( 0 => int k; k < fxChain.cap(); k++ ) {
            if ( k != i ) {
                fxChain[k] @=> newFxChain[j];
                j++;
            }
        }
        // getCurrentFxCount();
        newFxChain @=> fxChain;
        removeFromChain( i, fx );
    }

    fun void addToChain( int i, Fx newFx ) {
        // spork ~ newFx.initialise();
        spork ~ newFx.initialise();
        <<< "addToChain() adding", newFx.idString(), "key", i >>>;

        if ( i == 0 ) {
            <<< "   i==0" >>>;
            // sample.connect( newFx.inputL, newFx.inputR );
            // newFx.outputL => dac.left;
            // newFx.outputR => dac.right;
            sample.connect( newFx.inputL, newFx.inputR );
        }
        else {
            <<< "  i > 0, ", i >>>;
            // we need to get i - 1's out and plug in to
            // i's input
            // are you keeping up?
            fxChain[ i - 1 ] @=> Fx upstreamFx;
            // <<< "   PREEVIOUS", upstreamFx.idString() >>>;
            upstreamFx.outputL =< dac.left;
            upstreamFx.outputR =< dac.right;

            upstreamFx.outputL => newFx.inputL;
            upstreamFx.outputR => newFx.inputR;
        }

        newFx.outputL => dac.left;
        newFx.outputR => dac.right;

        10::second => now;
    }

    fun void removeFromChain( int i, Fx fx ) {
        Fx upstreamFx, downstreamFx;
        0 => int deleteFromDac;
        0 => int downstreamPresent;

        if ( i < ( maxConcurrentFx - 1 ) && fxChain[ i + 1 ] != NULL ) {
            fxChain[ i + 1 ] @=> downstreamFx;
            1 => downstreamPresent;
        }
        <<< downstreamPresent >>>;

        if ( i == 0 ) {
            <<< "   i==0" >>>;
            sample.disconnect( fx.inputL, fx.inputR );

            // work out how what to disconnect from output wise
            if ( downstreamPresent ) {
                <<< "   disconnecting from downstream 1" >>>;
                fx.outputL =< downstreamFx.inputL;
                fx.outputR =< downstreamFx.inputR;
            }
            else {
                <<< "   deleteFromDac set 1" >>>;
                1 => deleteFromDac;
            }
        }
        else {
            // we've got something in the chain behind us, so
            // disconnect from that
            <<< "   i != 0" >>>;
            fxChain[ i - 1 ] @=> Fx upstreamFx;

            upstreamFx.outputL =< fx.inputL;
            upstreamFx.outputR =< fx.inputR;

            if ( downstreamPresent ) {
                <<< "   disconnecting from downstream 2" >>>;
                fx.outputL =< downstreamFx.inputL;
                fx.outputR =< downstreamFx.inputR;
            }
            else {
                <<< "   deleteFromDac set 2" >>>;
                1 => deleteFromDac;
            }
        }

        if ( deleteFromDac ) {
            // disconnect from dac
            fx.outputL =< dac.left;
            fx.outputR =< dac.right;
        }

        // fx.tearDown();
    }
}
