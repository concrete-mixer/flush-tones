public class FxFreqMod extends Fx {
    fun string idString() { return "FxFreqMod"; }

    fun void initialise()    {
        Modulate mod;
        input => mod => output;
        chooser.getFloat( 0.1, 25.0 ) => mod.vibratoRate;
    }
}
