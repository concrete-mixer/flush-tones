
public class FxFlanger extends Fx {
    LFO lfo;
    DelayA flanger;
    Gain feedback;
    90 => float bpmInterval;
    bpmInterval * 4.0 => float barInterval;

    [
        bpmInterval / 2.0,
        bpmInterval * ( 2.0 / 3.0 ),
        bpmInterval,
        bpmInterval * 1.5,
        bpmInterval * ( 3.0 / 2.0 ),
        bpmInterval * 2.0,
        bpmInterval * 2.5,
        bpmInterval * 3.0
    ] @=> float flangeFreqsShort[];

    [
        barInterval,
        barInterval * 2.0,
        barInterval * 3.0,
        barInterval * 4.0,
        barInterval * 5.0,
        barInterval * 6.0,
        barInterval * 8.0,
        barInterval * 9.0,
        barInterval * 12.0,
        barInterval * 16.0
    ] @=> float flangeFreqsLong[];

    float oscFreq, oscAmount, volFreq, volAmount, baseDelay;
    string oscType, volType;

    fun string idString() { return "FxFlanger"; }

    fun void initialise() {
        input => flanger => output;
        flanger => feedback => input;

        // choose to go with slow and heavy flange
        // or fast and light
        chooser.getInt( 1, 2 ) => int flangeType;

        // 1 == slow
        if ( flangeType == 1 ) {
            1 / flangeFreqsLong[ chooser.getInt( 0, flangeFreqsLong.cap() - 1 ) ] => oscFreq;
            chooser.getFloat( 1, 5 ) => baseDelay;
            chooser.getFloat( 1, baseDelay - 0.1 ) => oscAmount;
            chooser.getFloat( 0.05, 0.25 ) => volFreq;
            chooser.getFloat( 0.5, 0.9 ) => volAmount;
            "sine" => oscType;
            "sine" => volType;
        }
        // 2 == fast
        else {
            1 / flangeFreqsShort[ chooser.getInt( 0, flangeFreqsShort.cap() - 1 ) ] => oscFreq;
            chooser.getFloat( 1, 2.5 ) => baseDelay;
            chooser.getFloat( 1, baseDelay - 0.1 ) => oscAmount;
            chooser.getFloat( 0.1, 0.5 ) => volFreq;
            chooser.getFloat( 0.5, 0.8 ) => volAmount;
            getOscType() => oscType;
            "sine" => volType;
        }

        <<< "   FxFlanger", "flangeType", flangeType, "oscType:", oscType, "volType:", volType, "oscFreq:", oscFreq, "volFreq:", volFreq, "oscAmount:", oscAmount, "volAmount:", volAmount, "baseDelay:", baseDelay >>>;

        0 => feedback.gain;
        baseDelay::ms => flanger.delay;
        2000::ms => flanger.max;

        spork ~ activity();
    }

    fun string getOscType() {
        chooser.getInt( 1, 4 ) => int choice;

        // sine is best but sampleHold on flange is a bit of
        // a novelty, so keeping
        if ( choice == 1 ) {
            return "sampleHold";
        }
        else {
            return "sine";
        }
    }

    fun void activity() {
        while ( active ) {
            lfo.osc( oscFreq, oscAmount, oscType ) => float freqDelta;
            baseDelay::ms + freqDelta::ms => flanger.delay;
            lfo.osc( volFreq, volAmount, volType ) => feedback.gain;
            10::ms => now;
        }
    }

    fun void tearDown() {
        input =< flanger =< output;
        flanger =< feedback =< input;
        0 => active;
    }
}
