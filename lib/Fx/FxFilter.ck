public class FxFilter extends Fx {
    FilterBasic filter;
    LFO lfo;

    fun string idString() { return "FxFilter"; }

    fun void initialise() {
        chooser.getInt( 0, 2 ) => int typeChoice;

        // baseFilterFreq is base frequency for filter
        // may or may not end up being oscillated
        float baseFilterFreq;
        chooser.getFloat( 400, 800 ) => baseFilterFreq;

        string filterChosen;

        if ( typeChoice == 0 ) {
            LPF lpf @=> filter;

            // for lpf, we want a lowish base freq
            "LPF" => filterChosen;
        }

        if ( typeChoice == 1 ) {
            HPF hpf @=> filter;
            "HPF" => filterChosen;
        }

        if ( typeChoice == 2 ) {
            BPF bpf @=> filter;
            "BPF" => filterChosen;
        }

        input => filter => output;

        // set baseFilterFreq
        baseFilterFreq => filter.freq;

        // set Q between 1 and 5
        chooser.getFloat( 5, 10 ) => float Q;
        Q => filter.Q;
        <<< "FxFilter:", filterChosen, "at", baseFilterFreq, "Hz", Q, "q" >>>;

        // determine whether to oscillate (mostly yes)
        if ( chooser.takeAction( 1 ) ) {
            float amount;
            // as a rule amount should be less than basefreq over 2
            chooser.getFloat( baseFilterFreq / 3, baseFilterFreq / 3 + baseFilterFreq / 6 ) => amount;

            // determine oscillation function
            // square doesn't work very well, so we're defining our own
            "sine" => string oscType;

            // sampleHold is cool, but better in small doses
            chooser.getInt(0,3) => int choice;
            if ( choice == 0 ) {
                "sampleHold" => oscType;
            }

            chooser.getFloat( 0.05, 0.5 ) => float lfoFreq;

            // sample hold is better when its faster...
            if ( oscType != "sine" ) {
                lfoFreq * 20 => lfoFreq;
            }

            while ( true ) {
                lfo.osc( lfoFreq, amount, oscType ) => float freqDelta;
                baseFilterFreq + freqDelta => filter.freq;
                100::ms => now;
            }
        }
    }
}
