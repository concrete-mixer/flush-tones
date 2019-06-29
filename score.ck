me.dir() => string path;
Chooser chooser;
Dyno dynoL => dac.left;
Dyno dynoR => dac.right;

WvOut2 wv;
"flush" => wv.autoPrefix;
"special:auto" => wv.wavFilename;
dac => wv => blackhole;

0 => dynoL.gain;
0 => dynoR.gain;

dynoL.limit();
dynoR.limit();
1 => int active;

FxManager fxManager;

_setFiles(["audio/loops"]) @=> string loopFilesList[];

[
    "audio/one-shot/instrumental/saxophone",
    "audio/one-shot/instrumental/trumpet",
    "audio/one-shot/instrumental/tuba",
    "audio/one-shot/instrumental/bassoon",
    "audio/one-shot/instrumental/contra-bassoon",
    "audio/one-shot/concrete"
] @=> string oneShotFileDirs[];

_setFiles(oneShotFileDirs) @=> string oneShotFilesList[];

stanza();

Machine.add("score.ck");

// FUNCTIONS FOLLOW
fun string[] _setFiles(string fileDirs[]) {
    FileIO fileList;

    string allFiles[0];

    for (0 => int i; i < fileDirs.cap(); i++) {
        fileDirs[i] => string dirPath;
        fileList.open(me.dir() + dirPath);

        _processFileList( fileList.dirList(), me.dir() + dirPath) @=> string files[];

        fileList.close();

        for (0 => int j; j < files.cap(); j++) {
            <<< files[j] >>>;
            allFiles << files[j];
        }
    }

    return allFiles;
}

fun string[] _processFileList( string fileList[], string path ) {
    string soundsFound[0];

    for ( 0 => int i; i < fileList.cap(); i++ ) {
        if ( RegEx.match(".(wav|aif|aiff)$", fileList[i]) ) {
            soundsFound << path + "/" + fileList[i];
        }
    }

    return soundsFound;
}

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

    60::second => now;

    spork ~ fader.fadeOut( fadeTime, dynoL );
    spork ~ fader.fadeOut( fadeTime, dynoR );

    fadeTime => now;

    0 => active;
    spork ~ fxManager.tearDown();
    fadeTime => now;

    FxManager newFxManager;
    newFxManager @=> fxManager;
}

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
            waitTime => now;
        }
    }
}

fun void playSnd( string files[] ) {
    chooser.getInt( 0, files.cap() - 1 ) => int choice;
    Sample sample;

    chooser.takeAction( 3 ) => int fxOn;
    <<< "playing", files[choice] >>>;
    spork ~ sample.initialise( files[choice], 0, 0.8, dynoL, dynoR );

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
