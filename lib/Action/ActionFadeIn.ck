public class ActionFadeIn extends Action {
    fun dur execute( Sample sample ) {
        chooser.getDur( 1, 5 ) => dur fadeTime;
        "in" => string fadeState;
        spork ~ sample.changeFade( fadeState, fadeTime );
        return fadeTime;
    }
}
