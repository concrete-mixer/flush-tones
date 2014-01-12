public class FxDelay extends Fx {
    Echo echo;
    input => echo => output;

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

        echo.delay( leftLength );
        echo.mix( echoMix );

        while ( active ) {
            1::second => now;
        }
        <<< "FxDelay.execute(): completing FxDelay" >>>;
    }
}
