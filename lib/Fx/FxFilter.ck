public class FxFilter extends Fx {
    FilterBasic filter;
    LFO lfo;

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

        <<< "we're going", filterChosen >>>;
        input => filter => output;

        // set baseFilterFreq
        baseFilterFreq => filter.freq;

        // set Q between 1 and 5
        chooser.getFloat( 3, 10 ) => float Q;
        Q => filter.Q;

        // determine whether to oscillate (mostly yes)
        if ( chooser.takeAction( 1 ) ) {
            float amount;
            // as a rule amount should be less than basefreq over 2
            chooser.getFloat( baseFilterFreq / 2, baseFilterFreq / 2 + baseFilterFreq / 4 ) => amount;
            // determine oscillation function
            lfo.getOscType() => string oscType;
            <<< "we're oscillating with", oscType >>>;
            chooser.getFloat( 0.05, 0.5 ) => float lfoFreq;

            // sample hold is better when its faster...
            if ( oscType != "sine" ) {
                lfoFreq * 10 => lfoFreq;
            }
            "sampleHold" => oscType;
            while ( true ) {
                lfo.osc( lfoFreq, amount, oscType ) => float freqDelta;
                baseFilterFreq + freqDelta => filter.freq;
                100::ms => now;
            }
        }
    }
}
