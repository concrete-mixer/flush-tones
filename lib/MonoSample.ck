public class MonoSample extends Sampler {
    SndBuf buf;
    0 => buf.gain;
    PanMono pan;
    "out" => string fadeState;
    0.8 => float maxVol;

    fun void instantiate(string filepath, int loop) {
        buf => pg.mono;
        buf.read(filepath);
        setLoop( loop );
    }

    fun void setLoop( val ) {
        val => buf.loop;
    }

    fun void changeFade( string targetState, float fadeTime, Pan2 pan ) {
        fadeTime / 1000 => float timeIncrement;
        float currentVol;

        float volIncrement;
        maxVol / 1000 => volIncrement;

        if ( targetState == "out" ) {
            maxVol => currentVol;
            -volIncrement => volIncrement;
        }

        <<< "fadeTime", fadeTime, "timeIncrement", timeIncrement, "volIncrement", volIncrement >>>;

        while ( fadeTime > 0 ) {
            volIncrement +=> currentVol;
            currentVol => pan.gain;
            timeIncrement -=> fadeTime;
            timeIncrement::second => now;
        }

        targetState => fadeState;
    }

    while ( true ) {
        // do something to make things happen
    }
}
