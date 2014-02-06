public class FxPhaser extends Fx {
    fun string idString() { return "FxPhaser"; }

    chooser.getInt( 2, 12 ) => int stagesCount;
    <<< "Phaser stages:", stagesCount >>>;

    fun void initialise() {
        <<< "called!" >>>;
        PoleZero poleChain[ stagesCount ];

        input => poleChain[ 0 ];

        for ( 1 => int i; i < stagesCount; i++ ) {
            poleChain[ i - 1 ] => poleChain[ i ];
        }

        Gain outWet => output;
        poleChain[ stagesCount - 1 ] => outWet;

        output => Gain feedbackGain => input;
        input => Gain outDry => output;
        0.8 => feedbackGain.gain;
        0.5 => outDry.gain;
        0.5 => outWet.gain;

        SinOsc lfoSin => Gain lfo => blackhole;
        chooser.getFloat( 0.05, 0.2 ) => float oscFreq;
        <<< "Phaser LFO speed", oscFreq >>>;
        oscFreq => lfoSin.freq;
        0.5 => lfoSin.gain;
        Step lfoShift => lfo;
        0.5 => lfoShift.next;

        while(true) {
            for ( 1 => int i; i < stagesCount; i++ ) {
                // <<< lfo.last() >>>;
                lfo.last() => poleChain[i].allpass;
            }

            // chooser.getInt( 10, 100 ) => int waitTime;
            // waitTime::ms => now;

            100::ms => now;
        }
    }
}
