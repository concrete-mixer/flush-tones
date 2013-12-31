public class Scheduler extends Chooser {
    // set up our action data

    // actionBattery an array of effects to apply to a sample
    Action @ actionBattery[3];
    new ActionSampleReverse @=> actionBattery[0];
    new ActionDelay @=> actionBattery[1];
    new ActionFadeOut @=> actionBattery[2];

    ActionFadeIn fadeIn;
    // ActionFadeOut fadeOut;

    // keep guages of number of effects in operation
    // rather than apply effects one at a time
    0 => int actionCurrentCount;

    int actionCurrentStore[0];

    fun void schedule( Sample sample ) {
        while ( true ) {
            dur waitDur;
            <<< "actionCurrentCount", actionCurrentCount >>>;

            // if the sample is currently faded out, our response should be to
            // fade it in
            <<< "sample.fadeState", sample.fadeState >>>;

            if ( takeAction( 1 ) ) {
                if ( sample.fadeState == "out" ) {
                    <<< "fading in" >>>;
                    fadeIn.execute( sample ) => waitDur;
                }
                else if ( actionCurrentCount < 3 ) {
                    <<< "Sporking!" >>>;
                    spork ~ determineAction( sample );
                }
            }

            // define waitDur if not already defined
            if ( waitDur == 0::second ) {
                wait( 5, 10 ) => waitDur;
            }

            <<< "Waiting", waitDur / 44100, "seconds" >>>;
            waitDur => now;
        }
    }

    fun dur determineAction( Sample sample ) {
        actionCurrentCount++;
        dur actionDuration;

        Math.random2( 0, actionBattery.cap() - 1 ) => int i;

        if ( actionInstanceCheck(i) ) {
            actionBattery[i].execute( sample ) => dur actionDuration;
            <<< "Action took", actionDuration / 44100, "seconds", actionCurrentCount >>>;
        }

        actionCurrentCount--;
        me.exit();
    }

    fun int actionInstanceCheck( int i ) {
        actionBattery[i].idString() => string idString;

        if ( actionCurrentStore[ idString ] == 1 ) {
            return 0;
        }
        else {
            1 => actionCurrentStore[ idString ];
            return 1;
        }
    }
}
