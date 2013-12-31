public class Fader {
    0.8 => static float maxGain;

    fun static dur getTimeIncrement( dur fadeTime ) {
        return fadeTime / 1000;
    }

    fun static float getGainIncrement() {
        return maxGain / 1000;
    }
}
