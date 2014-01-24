me.dir() => string path;
Chooser chooser;
Dyno dynoL => dac.left;
Dyno dynoR => dac.right;

dynoL.limit();
dynoR.limit();

FxManager fxManager;
fxManager.initialise( dynoL, dynoR );

fun void initSample(string filepath, int loop, float gain, UGen leftOut, UGen rightOut ) {
    Sample sample;
    if ( chooser.getInt( 1, 1 ) ) {
        fxManager.connect( sample.out );
    }

    spork ~ sample.initialise( filepath, loop, gain, leftOut, rightOut );
}

// initSample(path + "audio/santorini_cistern2.wav", 1, 0.5, dynoL, dynoR );
// initSample(path + "audio/drip-no-hum-full2.wav", 1, 0.5, dynoL, dynoR );
// initSample(path + "audio/drip-hum-sub2.wav", 1, 0.5, dynoL, dynoR );
initSample(path + "audio/refill-loop.wav", 1, 0.5, dynoL, dynoR );
initSample(path + "audio/refill-tickley-burble.wav", 1, 0.5, dynoL, dynoR );
// initSample(path + "audio/switch-lights-loop.wav", 1, 0.5, dynoL, dynoR );

[
    path + "audio/santorini_cistern2.wav",
    path + "audio/drip-no-hum-full2.wav",
    path + "audio/drip-hum-sub2.wav",
    path + "audio/refill-loop.wav",
    path + "audio/refill-tickley-burble.wav",
    path + "audio/switch-lights-loop.wav"
] @=> string loopFilesList[];

[
    path + "audio/tuba/2748_tuba_023_5_7_1.mp3.wav",
    path + "audio/tuba/2513_tuba_043_4_5_1.mp3.wav",
    path + "audio/bassoon/2166_bassoon_036_4_7_1.mp3.wav",
    path + "audio/bassoon/2385_bassoon_077_2_7_1.mp3.wav",
    path + "audio/saxophone/1390_saxophone_057_2_9_1.mp3.wav",
    path + "audio/saxophone/1811_saxophone_067_3_6_1.mp3.wav"
] @=> string tunedFilesList[];

[
    path + "audio/flush-short2.wav",
    path + "audio/switch-lights-loop.wav",
    path + "audio/foot-on-grill3.wav",
    path + "audio/flush-lever-flick.wav"
] @=> string concreteFilesList[];

chooser.selectFiles( tunedFilesList, 4 ) @=> string tunedFiles[];
chooser.selectFiles( concreteFilesList, 4 ) @=> string concreteFiles[];

WaveBank tunedBank;
WaveBank concreteBank;
spork ~ tunedBank.initialise( tunedFiles, fxManager, dynoL, dynoR, 3, 10 );
spork ~ concreteBank.initialise( concreteFiles, fxManager, dynoL, dynoR, 2, 10 );

// keep things ticking over
while ( true ) {
    <<< "ping..." >>>;
    5::second => now;
}
