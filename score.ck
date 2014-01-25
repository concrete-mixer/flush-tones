me.dir() => string path;
Chooser chooser;
Dyno dynoL => dac.left;
Dyno dynoR => dac.right;
Fader fader;

dynoL.limit();
dynoR.limit();
// 0 => dynoL.gain;
// 0 => dynoR.gain;

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

initLoops( loopFiles, 0.5 );
spork ~ schedule( oneShotFiles, 1,3 );

fun void initLoops(string files[], float gain ) {
    for ( 0 => int i; i < files.cap(); i++ ) {
        Sample sample;
        sample.initialise( files[i], 1, gain, dynoL, dynoR );

        if ( chooser.getInt( 1, 1 ) ) {
            fxManager.connect( sample.buf );
        }
    }
}

// plan here is generate a random sequence of samples
fun void schedule( string files[], int waitMin, int waitMax ) {
    while ( true ) {
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

fun dur playSnd( string files[] ) {
    printFiles( files );
    chooser.getInt( 0, files.cap() - 1 ) => int choice;
    Sample sample;

    chooser.takeAction( 3 ) => int fxOn;

    if ( fxOn ) {
        <<< "FX!!!" >>>;
        sample.buf => fxManager.connect;
    }

    sample.initialise( files[choice], 0, 0.25, dynoL, dynoR );
    sample.buf.length() => now;

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

while ( true ) {
    <<< "ping..." >>>;
    5::second => now;
}
