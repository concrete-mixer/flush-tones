public class FxChorus extends Fx {
    Chorus chorus;

    input => chorus => output;

    fun string idString() { return "FxChorus"; }

    fun void initialise() {
        1 => active;

        chooser.getFloat( 0.1, 4 ) => float freq;
        float depth;

        if ( freq < 2 ) {
            chooser.getFloat( 0.3, 0.6 ) => float depth;
        }
        else {
            chooser.getFloat( 0.1, 0.3 ) => float depth;
        }

        chooser.getFloat( 0.3, 0.8 ) => float mix;

        freq => chorus.modFreq;
        depth => chorus.modDepth;
        mix => chorus.mix;
    }
}
