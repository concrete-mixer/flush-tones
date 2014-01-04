public class ActionChangeFx extends Action {
    FxManager fxManager;

    0 => int called;

    fun string idString() { return "ActionChangeFx"; }

    fun dur execute( Sample sample ) {
        // determine what to do; if no current effects definitely add one
        // if ( called ) {
        // }
        // else {
            1 => called;
            fxManager.initialise( sample );
            fxManager.getCurrentFxCount() => int currentFxCount;

            if ( ! currentFxCount ) {
                <<< "no effects currently, adding", called >>>;
                fxManager.addFx();
            }
            else {
                // if we already have all our effects in use, remove one
                if ( currentFxCount == fxManager.maxConcurrentFx ) {
                    <<< "max effects in use, removing" >>>;
                    fxManager.removeFx();
                }
                else {
                    // coin toss
                    if ( chooser.getInt( 0, 1 ) ) {
                        fxManager.addFx();
                    }
                    else {
                        fxManager.removeFx();
                    }
                }
            }
        // }
    }
}
