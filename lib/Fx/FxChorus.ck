public class FxChorus extends Fx {
    Chorus chorus;

    input => chorus => output;

    fun string idString() { return "FxChorus"; }

    fun void initialise() {
        1 => active;
<<< "INITIALISING CHORUS">>>;
        chooser.getFloat( 0.1, 4 ) => float freq;
        float depth;

        if ( freq < 1 ) {
            chooser.getFloat( 0.3, 0.8 ) => float depth;
            <<< "kings of low frequencies", depth >>>;
        }
        else {
            chooser.getFloat( 0.05, 0.99 ) => float depth;
            <<< "kings of high frequency", depth >>>;
        }

        chooser.getFloat( 0.3, 0.8 ) => float mix;

        freq => chorus.modFreq;
        depth => chorus.modDepth;
        mix => chorus.mix;
    }
}
