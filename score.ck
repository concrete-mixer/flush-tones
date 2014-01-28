me.dir() => string path;
Chooser chooser;
Dyno dynoL => dac.left;
Dyno dynoR => dac.right;

0 => dynoL.gain;
0 => dynoR.gain;

dynoL.limit();
dynoR.limit();
1 => int active;

FxManager fxManager;

[
    path + "audio/santorini_cistern2.wav",
    path + "audio/drip-no-hum-full2.wav",
    path + "audio/drip-hum-sub2.wav",
    path + "audio/refill-loop.wav",
    path + "audio/refill-tickley-burble.wav",
    path + "audio/switch-lights-loop.wav",
    path + "audio/abashiri-aircon.wav"
] @=> string loopFilesList[];

[
    // here follow the tuned samples
    // bassoon:
    path + "audio/bassoon/1987_bassoon_042_3_6_1.mp3.wav",
    path + "audio/bassoon/1989_bassoon_043_1_6_1.mp3.wav",
    path + "audio/bassoon/2028_bassoon_053_4_6_1.mp3.wav",
    path + "audio/bassoon/2073_bassoon_065_2_6_1.mp3.wav",
    path + "audio/bassoon/2078_bassoon_066_4_6_1.mp3.wav",
    path + "audio/bassoon/2082_bassoon_067_4_6_1.mp3.wav",
    path + "audio/bassoon/2086_bassoon_068_4_6_1.mp3.wav",
    path + "audio/bassoon/2166_bassoon_036_4_7_1.mp3.wav",
    path + "audio/bassoon/2187_bassoon_043_2_7_1.mp3.wav",
    path + "audio/bassoon/2212_bassoon_051_4_7_1.mp3.wav",
    path + "audio/bassoon/2253_bassoon_055_3_7_1.mp3.wav",
    path + "audio/bassoon/2318_bassoon_073_3_7_1.mp3.wav",
    path + "audio/bassoon/2385_bassoon_077_2_7_1.mp3.wav",
    path + "audio/bassoon/2399_bassoon_034_2_9_1.mp3.wav",
    path + "audio/bassoon/2559_bassoon_034_4_10_1.mp3.wav",
    path + "audio/bassoon/2588_bassoon_042_1_10_1.mp3.wav",
    path + "audio/bassoon/2679_bassoon_068_2_10_1.mp3.wav",
    path + "audio/bassoon/2787_bassoon_055_6_3_1.mp3.wav",

    // tuba:
    path + "audio/tuba/3228_tuba_047_3_10_23.mp3.wav",
    path + "audio/tuba/2632_tuba_031_4_6_1.mp3.wav",
    path + "audio/tuba/3127_tuba_045_5_8_11.mp3.wav",
    path + "audio/tuba/3171_tuba_039_3_9_16.mp3.wav",
    path + "audio/tuba/2879_tuba_022_5_8_1.mp3.wav",
    path + "audio/tuba/3103_tuba_053_2_10_1.mp3.wav",
    path + "audio/tuba/3062_tuba_031_2_10_1.mp3.wav",
    path + "audio/tuba/2466_tuba_032_1_5_1.mp3.wav",
    path + "audio/tuba/2986_tuba_025_5_9_1.mp3.wav",
    path + "audio/tuba/2513_tuba_043_4_5_1.mp3.wav",
    path + "audio/tuba/2748_tuba_023_5_7_1.mp3.wav",
    path + "audio/tuba/3131_tuba_057_5_8_11.mp3.wav",

    // saxophone:
    path + "audio/saxophone/1054_saxophone_063_2_5_1.mp3.wav",
    path + "audio/saxophone/1516_saxophone_059_4_10_1.mp3.wav",
    path + "audio/saxophone/1029_saxophone_057_1_5_1.mp3.wav",
    path + "audio/saxophone/1494_saxophone_053_4_10_1.mp3.wav",
    path + "audio/saxophone/1502_saxophone_055_4_10_1.mp3.wav",
    path + "audio/saxophone/1811_saxophone_067_3_6_1.mp3.wav",
    path + "audio/saxophone/1069_saxophone_068_3_5_1.mp3.wav",
    path + "audio/saxophone/1037_saxophone_058_1_5_1.mp3.wav",
    path + "audio/saxophone/1390_saxophone_057_2_9_1.mp3.wav",
    path + "audio/saxophone/1026_saxophone_055_4_5_1.mp3.wav",
    path + "audio/saxophone/1318_saxophone_059_1_5_1.mp3.wav",

    // here follow the concrete samples
    path + "audio/concrete-oneshot/flush-short2.wav",
    path + "audio/concrete-oneshot/foot-on-grill3.wav",
    path + "audio/concrete-oneshot/flush-lever-flick.wav",
    path + "audio/concrete-oneshot/bubble-1.wav",
    path + "audio/concrete-oneshot/bubble-2.wav",
    path + "audio/concrete-oneshot/bubble-3.wav"
] @=> string oneShotFilesList[];


fun void stanza() {
    1 => active;
    chooser.selectFiles( loopFilesList, 2 ) @=> string loopFiles[];
    chooser.selectFiles( oneShotFilesList, 4 ) @=> string oneShotFiles[];
    fxManager.initialise( dynoL, dynoR );

    spork ~ initLoops( loopFiles, 0.5 );
    spork ~ schedule( oneShotFiles, 1, 3 );
    Fader fader;
    5::second => dur fadeTime;

    // dyno gain out still zero - to avoid pi *hearing* the pi flaking out while the samples are loaded, tick over a couple of seconds then fade the dynos in
    2::second => now;

    spork ~ fader.fadeIn( fadeTime, 0.8, dynoL );
    spork ~ fader.fadeIn( fadeTime, 0.8, dynoR );

    100::second => now;

    spork ~ fader.fadeOut( fadeTime, dynoL );
    spork ~ fader.fadeOut( fadeTime, dynoR );

    fadeTime => now;

    0 => active;
    spork ~ fxManager.tearDown();
    fadeTime => now;

    FxManager newFxManager;
    newFxManager @=> fxManager;
}

stanza();

// FUNCTIONS FOLLOW
fun void initLoops(string files[], float gain ) {
    printFiles( files );

    Sample @ samples[ files.cap() ];

    for ( 0 => int i; i < files.cap(); i++ ) {
        Sample sample;
        <<< "sporking", files[i] >>>;
        spork ~ sample.initialise( files[i], 1, gain, dynoL, dynoR );

        if ( chooser.getInt( 1, 1 ) ) {
            fxManager.connect( sample.buf );

            // we've added a wet output for the sample
            // now tell it to consider resetting its dry output
            sample.setMixChoice();
        }

        sample @=> samples[ i ];
    }

    while ( active ) {
        5::second => now;
    }

    for ( 0 => int i; i < samples.cap(); i++ ) {
        samples[ i ] @=> Sample sample;
        spork ~ sample.tearDown();
    }

    return;
}

// plan here is generate a random sequence of samples
fun void schedule( string files[], int waitMin, int waitMax ) {
    while ( active ) {
        if ( chooser.takeAction( 3 ) ) {
            playSnd( files );
        }
        else {
            dur waitTime;
            chooser.getWait( waitMin, waitMax ) => waitTime;
            <<< "passing time", waitTime / 44100 >>>;
            waitTime => now;
        }
    }
}

fun void playSnd( string files[] ) {
    chooser.getInt( 0, files.cap() - 1 ) => int choice;
    Sample sample;

    chooser.takeAction( 3 ) => int fxOn;
    spork ~ sample.initialise( files[choice], 0, 0.25, dynoL, dynoR );

    // this is a bit ugly, but we have to spork the line above and wait...
    until ( sample.buf.length() ) {
        1::ms => now;
    }
    if ( fxOn ) {
        sample.buf => fxManager.connect;
        sample.setMixChoice();
    }

    sample.buf.length() => now;
    sample.tearDown();

    if ( fxOn ) {
        sample.buf => fxManager.disconnect;
    }
}

fun void printFiles( string files[] ) {
    0 => int i;

    while( i < files.cap() ) {
        <<< "file:", files[i] >>>;
        i++;
    }
}
