public class FxChorus extends Fx {
    Chorus chorusL, chorusR;

    inputL => chorusL => outputL;
    inputR => chorusR => outputR;

    fun string idString() { return "FxChorus"; }

    fun void initialise() {
        1 => active;

        chooser.getFloat( 0.1, 4 ) => float freq;
        chooser.getFloat( 0.3, 0.6 ) => float depth;
        chooser.getFloat( 0.3, 0.8 ) => float mix;

        freq => chorusL.modFreq;
        depth => chorusL.modDepth;
        mix => chorusL.mix;

        freq => chorusR.modFreq;
        depth => chorusR.modDepth;
        mix => chorusR.mix;
    }
}
