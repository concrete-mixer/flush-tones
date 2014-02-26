public class FxDelayVariable extends Fx {
    DelayL delay;
    input => delay => output;
    Gain feedback;
    -0.50 => feedback.gain;
    delay => feedback;
    feedback => input;

    fun string idString() {
        return "FxDelayVariable";
    }

    fun void initialise() {
        1 => active;
        2000::ms => delay.max;

        while ( active ) {
            chooser.getDur( 0.05, 0.50 ) => dur dur;
            dur => now;
            chooser.getDur( 0.05, 0.50 ) => delay.delay;
        }
    }
}
