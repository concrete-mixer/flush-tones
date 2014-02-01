public class FxDelay extends Fx {
    Delay delay;
    input => delay => output;
    Gain feedback;
    0.5 => feedback.gain;
    delay => feedback;
    feedback => input;

    fun string idString() {
        return "FxDelay";
    }

    fun void initialise() {
        <<< "FxDelay.initialise() doing stuff" >>>;
        1 => active;
        chooser.getInt( 500, 2000 ) => int delayLength;
        chooser.getInt( 500, 5000 ) => int delayMax;
        <<< "delayLength", delayLength >>>;
        <<< "delayMax", delayMax >>>;
        chooser.getFloat( 0.2, 0.8 ) => float delayMix;

        delayMax::ms => delay.max;
        delayLength::ms => delay.delay;
        delayMix => output.gain;

        while ( active ) {
            1::second => now;
        }
        <<< "FxDelay.execute(): completing FxDelay" >>>;
    }
}
