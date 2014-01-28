public class FxChorus extends Fx {
    Chorus chorus;

    input => chorus => output;

    fun string idString() { return "FxChorus"; }

    fun void initialise() {
        1 => active;
        chooser.getFloat( 0.1, 4 ) => float freq;
        float depth;

        if ( freq < 1 ) {
            chooser.getFloat( 0.3, 0.8 ) => depth;
        }
        else {
            chooser.getFloat( 0.05, 0.10 ) => depth;
        }

        chooser.getFloat( 0.3, 0.7 ) => float mix;

        freq => chorus.modFreq;
        <<< "Chorus: freq", freq, "depth", depth, "mix", mix >>>;
        depth => chorus.modDepth;
        mix => chorus.mix;
    }
}
