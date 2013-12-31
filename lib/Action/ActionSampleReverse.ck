public class ActionSampleReverse extends Action {
    fun string idString() { return "ActionSampleReverse"; }

    fun dur execute( Sample sample ) {
        <<< "executing SampleReverse" >>>;
        chooser.getDur( 0.5, 20 ) => dur reverseDuration;
        sample.reverse( reverseDuration );
        <<< "completing SampleReverse" >>>;
        return reverseDuration;
    }
}
