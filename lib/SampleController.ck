public class SampleController {
    Chooser chooser;

    ActionFadeIn fadeIn;
    ActionFadeOut fadeOut;

    FxManager fxManager;

    fun void initialise( Sample sample ) {
        getPlaybackDuration( sample ) => dur interval;
        fxManager.initialise( sample );
        fadeIn.execute( sample );
        interval => now;
        fadeOut.execute( sample );
    }

    fun dur getPlaybackDuration( Sample sample ) {
        <<< "hello?" >>>;
        sample.getSampleCount() => int sampleCount;
        chooser.getFloat( 0.5, 3.0) => float coefficient;
        ( sampleCount * coefficient)::samp => dur duration;
        return duration;
    }
}
