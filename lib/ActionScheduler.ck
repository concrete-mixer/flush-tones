public class ActionScheduler {
    Chooser chooser;

    // set up our action data
    // actionBattery an array of effects to apply to a sample
    Action @ actionBattery[1];
    new ActionChangeFx @=> actionBattery[0];
    // new ActionSampleReverse @=> actionBattery[0];
    // new ActionFadeOut @=> actionBattery[1];

    ActionFadeIn fadeIn;
    // ActionFadeOut fadeOut;

    FxManager fxManager;

    // keep guages of number of effects in operation
    // rather than apply effects one at a time
    0 => int actionCurrentCount;

    Action @ actionCurrentStore[0];

    fun void initialise( Sample sample, dur interval ) {
        schedule( sample, interval );
        fxManager.initialise( sample );
    }

    fun void schedule( Sample sample, dur interval ) {
        while ( true ) {
            // if the sample is currently faded out, our response should be to
            // fade it in

            if ( chooser.takeAction( 1 ) ) {
                if ( sample.fadeState == "out" ) {
                    fadeIn.execute( sample );
                }
                else if ( actionCurrentCount < 3 ) {
                    spork ~ determineAction( sample );
                }
            }

            interval => now;
        }
    }

    fun dur determineAction( Sample sample ) {
        actionCurrentCount++;
        dur actionDuration;
        chooser.getInt( 0, actionBattery.cap() - 1 ) => int i;

        if ( ! actionInstanceCheck(i) ) {
            actionBattery[i].execute( sample ) => dur actionDuration;
        }
        else {
            <<< "action of this type already being processed" >>>;
        }

        actionCurrentCount--;
        me.exit();
    }

    fun int actionInstanceCheck( int i ) {
        actionBattery[i].idString() => string idString;

        for ( 0 => int j; j < actionCurrentStore.cap() - 1; j++ ) {
            if ( actionCurrentStore[j].idString() == idString ) {
                if ( actionCurrentStore[j].checkRunning() ) {
                    <<< "chucklehead" >>>;
                    return 1;
                }
                else {
                    <<< "aha!" >>>;
                    // "delete" item from actionCurrentStore
                    deleteFromCurrentStore( j );
                    return 0;
                }
            }
        }
    }

    // Method to 'delete' a value from actionCurrentStore by
    // creating a new array and adding all elements but the value
    // we want deleted, then replacing actionCurrentStore with
    // the new array
    fun void deleteFromCurrentStore( int i ) {
        Action @ newActionCurrentStore[0];
        0 => int k;

        for( 0 => int j; j < actionCurrentStore.cap() - 1; j++ ) {
            if ( j != i ) {
                actionCurrentStore[j] @=> newActionCurrentStore[k];
                k++;
            }
        }

        newActionCurrentStore @=> actionCurrentStore;
    }
}
