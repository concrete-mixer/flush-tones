public class FxDelay extends Fx {
    Echo echoL, echoR;
    inputL => echoL => outputL;
    inputR => echoR => outputR;

    fun string idString() {
        return "FxDelay";
    }

    fun void initialise() {
        <<< "FxDelay.initialise() doing stuff" >>>;
        1 => active;
        chooser.getDur( 0.5, 20 ) => dur echoDuration;
        chooser.getDur( 0.02, 0.5 ) => dur leftLength;
        chooser.getDur( 0.02, 0.5 ) => dur rightLength;
        chooser.getFloat( 0.2, 0.8 ) => float echoMix;

        echoL.delay( leftLength );
        echoR.delay( rightLength );
        echoL.mix( echoMix );
        echoR.mix( echoMix );

        while ( active ) {
            <<< "FxDelay active" >>>;
            1::second => now;
        }
        <<< "FxDelay.execute(): completing FxDelay" >>>;
    }
}
