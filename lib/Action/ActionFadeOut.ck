public class ActionFadeOut extends Action {
    fun string idString() { return "ActionFadeOut"; }

    fun dur execute( Sample sample ) {
        chooser.getDur( 5, 20 ) => dur fadeTime;
        "out" => string fadeState;
        sample.changeFade( fadeState, fadeTime );
        return fadeTime;
    }
}
