public class FxReverb extends Fx {
    NRev revL, revR;
    inputL => revL => outputL;
    inputR => revR => outputR;

    fun string idString() { return "FxReverb"; }

    fun void initialise() {
        <<< "reverb initialised, nothing else to do" >>>;
    }
}
