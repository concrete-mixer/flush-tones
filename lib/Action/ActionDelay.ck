public class ActionDelay extends Action {
    fun string idString() {
        return "ActionDelay";
    }
    fun dur execute( Sample sample ) {
        <<< "executing FxDelay" >>>;
        chooser.getDur( 0.5, 20 ) => dur echoDuration;
        Echo echoL => dac.left;
        Echo echoR => dac.right;
        chooser.getDur( 0.02, 0.5 ) => dur leftLength;
        chooser.getDur( 0.02, 0.5 ) => dur rightLength;

        echoL.delay( leftLength );
        echoR.delay( rightLength );
        echoL.gain( 0.8 );
        echoR.gain( 0.8 );
        echoL.mix( 0.5 );
        echoR.mix( 0.5 );
        sample.connect( echoL, echoR );
        echoDuration => now;
        sample.disconnect( echoL, echoR );
        echoL =< dac.left;
        echoR =< dac.right;
        <<< "completing FxDelay" >>>;

        return echoDuration;
    }
}
