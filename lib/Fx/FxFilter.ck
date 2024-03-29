public class FxFilter extends Fx {
    FilterBasic filter;
    LFO lfo;
    float amount, lfoFreq, baseFilterFreq, Q;
    fun string idString() { return "FxFilter"; }

    fun void initialise() {
        chooser.getInt( 1, 2 ) => int typeChoice;

        // baseFilterFreq is base frequency for filter
        // may or may not end up being oscillated
        float baseFilterFreq;

        string filterChosen;

        if ( typeChoice == 0 ) {
            LPF lpf @=> filter;

            // for lpf, we want a lowish base freq
            "LPF" => filterChosen;
            chooser.getFloat( 700, 1500 ) => baseFilterFreq;
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
        chooser.getFloat( 1, 5 ) => float Q;
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
            // Actually, I've now decided sample hold is not cool at all
            // chooser.getInt(0,3) => int choice;
            // if ( choice == 0 ) {
            //     "sampleHold" => oscType;
            // }

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
