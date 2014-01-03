public class FxDelay extends Fx {
    Echo echoL, echoR;
    inputL => echoL => outputL;
    inputR => echoR => outputR;

    fun string idString() {
        return "ActionDelay";
    }

    fun void initialise() {
        <<< "FxDelay.execute() doing stuff" >>>;
        // SinOsc s;
        // s.gain( 0.05 );
        // s => inputL;
        // s => inputR;
        // 440 => s.freq;
        chooser.getDur( 0.5, 20 ) => dur echoDuration;
        chooser.getDur( 0.02, 0.5 ) => dur leftLength;
        chooser.getDur( 0.02, 0.5 ) => dur rightLength;
        chooser.getFloat( 0.2, 0.8 ) => float echoMix;

        echoL.delay( leftLength );
        echoR.delay( rightLength );
        echoL.mix( echoMix );
        echoR.mix( echoMix );

        while ( active ) {
            // chooser.getInt( 220, 440 ) => s.freq;
            1::second => now;
        }
        <<< "FxDelay.execute(): completing FxDelay" >>>;
    }


    fun void tearDown() {
        0 => active;
    }
}
