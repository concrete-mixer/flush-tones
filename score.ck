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
fxManager.initialise( dynoL, dynoR );

[
    path + "audio/santorini_cistern2.wav",
    path + "audio/drip-no-hum-full2.wav",
    path + "audio/drip-hum-sub2.wav",
    path + "audio/refill-loop.wav",
    path + "audio/refill-tickley-burble.wav",
    path + "audio/switch-lights-loop.wav"
] @=> string loopFilesList[];

[
    // here follow the tuned samples
    path + "audio/tuba/2748_tuba_023_5_7_1.mp3.wav",
    path + "audio/tuba/2513_tuba_043_4_5_1.mp3.wav",
    path + "audio/bassoon/2166_bassoon_036_4_7_1.mp3.wav",
    path + "audio/bassoon/2385_bassoon_077_2_7_1.mp3.wav",
    path + "audio/saxophone/1390_saxophone_057_2_9_1.mp3.wav",
    path + "audio/saxophone/1811_saxophone_067_3_6_1.mp3.wav",

    // here follow the concrete samples
    path + "audio/flush-short2.wav",
    path + "audio/foot-on-grill3.wav",
    path + "audio/flush-lever-flick.wav"
] @=> string oneShotFilesList[];

chooser.selectFiles( loopFilesList, 2 ) @=> string loopFiles[];
chooser.selectFiles( oneShotFilesList, 4 ) @=> string oneShotFiles[];

spork ~ initLoops( loopFiles, 0.5 );
spork ~ schedule( oneShotFiles, 1, 3 );
Fader fader;
5::second => dur fadeTime;

// dyno gain out still zero - to avoid pi *hearing* the pi flaking out while the samples are loaded, tick over a couple of seconds then fade the dynos in
2::second => now;

spork ~ fader.fadeIn( fadeTime, 0.8, dynoL );
spork ~ fader.fadeIn( fadeTime, 0.8, dynoR );

20::second => now;

spork ~ fader.fadeOut( fadeTime, dynoL );
spork ~ fader.fadeOut( fadeTime, dynoR );

fadeTime => now;

0 => active;
spork ~ fxManager.tearDown();
fadeTime => now;

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
