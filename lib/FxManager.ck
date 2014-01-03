public class FxManager {
    Chooser chooser;
    1 => int maxConcurrentFx;
    Sample sample;

    Fx @ currentFx[ maxConcurrentFx ];
    Fx @ fxBattery[1];

    new FxDelay @=> fxBattery[0];
    0 => int currentFxCount;

    fun void initialise( Sample inputSample ) {
        <<< "yoohoo" >>>;
        inputSample @=> sample;
    }

    fun void addFx() {
        <<< "seriously, really?" >>>;
        chooser.getInt( 0, fxBattery.cap() - 1 ) => int i;
        FxDelay delay;
        <<< delay.idString() >>>;
        // delay @=> fxBattery[0];
        spork ~ delay.initialise();
        delay.outputL => dac.left;
        delay.outputR => dac.right;
        sample.connect( delay.inputL, delay.inputR );
        10::second => now;
        sample.disconnect( delay.outputL, delay.outputR );
        delay.tearDown();
        // <<< "fxBattery execution", i, fxBattery[i].idString() >>>;
        // addToCurrentFx( fxBattery[i] );
    }

    fun void removeFx() {
        getCurrentFxCount() => int currentFxCount;
        <<< "FxManager.removeFX() currentFxCount:", currentFxCount >>>;
        if ( currentFxCount ) {
            // we can assume that if we have any items we should get rid
            // of the first one (fifo)
            <<< "FxManager.removeFx(): removing", currentFx[0].idString() >>>;
            // removeFromCurrentFx( 0 );
            // currentFx[0].tearDown();
        }
        else {
            <<< "FxManager.removeFX() nothing to remove" >>>;
        }
    }

    fun int getCurrentFxCount() {
        0 => int currentFxCount;

        for( 0 => int i; i < currentFx.cap(); i++ ) {
            if ( currentFx[i] != NULL ) {
                <<< "   we have ", currentFx[i].idString() >>>;
                currentFxCount++;
            }
        }

        return currentFxCount;
    }

    // fun void addToCurrentFx( Fx fx ) {
    //     for( 0 => int i; i < currentFx.cap(); i++ ) {
    //         if ( currentFx[i] == NULL ) {
    //             // <<< "FxManager.addToCurrentFx: inserting", fx.idString() >>>;
    //             fx @=> currentFx[i];
    //             addToChain( i, fx );
    //             return;
    //         }
    //     }
    // }

    // fun void removeFromCurrentFx( int i ) {
    //     Fx @ newCurrentFx[3];
    //     0 => int j;

    //     for( 0 => int k; k < currentFx.cap(); k++ ) {
    //         if ( k != i ) {
    //             currentFx[i] @=> newCurrentFx[j];
    //             j++;
    //         }
    //         else {
    //             removeFromChain( i );
    //         }
    //     }

    //     newCurrentFx @=> currentFx;
    // }

    // fun void addToChain( int i, Fx newFx ) {
    //     // spork ~ newFx.initialise();
    //     <<< "bark" >>>;
    //     delay.initialise();

    //     if ( i == 0 ) {
    //         <<< "FxManager.currentFx(): i==0" >>>;
    //         // sample.connect( newFx.inputL, newFx.inputR );
    //         // newFx.outputL => dac.left;
    //         // newFx.outputR => dac.right;
    //         sample.connect( delay.inputL, delay.inputR );
    //         delay.outputL => dac.left;
    //         delay.outputR => dac.right;
    //     }
    //     else {
    //         <<< "FxManager.currentFx(): ", newFx.idString() >>>;
    //         // we need to get i - 1's out and plug in to
    //         // i's input
    //         // are you keeping up?
    //         currentFx[ i - 1 ] @=> Fx previousFx;
    //         previousFx.outputL =< dac.left;
    //         previousFx.outputR =< dac.right;
    //         // sample.disconnect( previousFx.inputL, previousFx.inputR );
    //         // previousFx.outputL => newFx.inputL;
    //         // previousFx.outputR => newFx.inputR;
    //         sample.disconnect( delay.inputL, delay.inputR );
    //     }
    // }

    // fun void removeFromChain( int i ) {
    //     // likewise
    // }
}
