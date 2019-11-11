me.dir() => string path;
Chooser chooser;
Dyno dynoL => dac.left;
Dyno dynoR => dac.right;

dynoL.limit();
dynoR.limit();

0 => dynoL.gain;
0 => dynoR.gain;

1 => int active;

FxManager fxManager;
me.arg(0) => string dirPath;
<<< dirPath + "/one-shot/concrete" >>>;
_setFiles([ dirPath + "/loops"]) @=> string loopFilesList[];

[
    dirPath + "/one-shot/instrumental/saxophone",
    dirPath + "/one-shot/instrumental/trumpet",
    dirPath + "/one-shot/instrumental/tuba",
    dirPath + "/one-shot/instrumental/bassoon",
    dirPath + "/one-shot/instrumental/contrabassoon",
    dirPath + "/one-shot/concrete"
] @=> string oneShotFileDirs[];

_setFiles(oneShotFileDirs) @=> string oneShotFilesList[];

5 => int oneShotBufsCount;
2 => int loopFileBufsCount;

SndBuf2 oneShotBufs[oneShotBufsCount];
SndBuf2 loopFileBufs[loopFileBufsCount];

stanza();

// FUNCTIONS FOLLOW
fun string[] _setFiles(string fileDirs[]) {
    FileIO fileList;

    string allFiles[0];

    for (0 => int i; i < fileDirs.cap(); i++) {
        fileDirs[i] => string dirPath;
        fileList.open(dirPath);

        _processFileList( fileList.dirList(), dirPath) @=> string files[];

        fileList.close();

        for (0 => int j; j < files.cap(); j++) {
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
    chooser.selectFiles( oneShotFilesList, 5 ) @=> string oneShotFiles[];
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
}

fun void initLoops(string files[], float gain ) {
    // Useful for debug
    // printFiles( files );

    Sample @ samples[ files.cap() ];

    for ( 0 => int i; i < files.cap(); i++ ) {
        Sample sample;

        <<< "sporking", files[i] >>>;
        spork ~ sample.initialise(files[i], loopFileBufs[i], 1, gain, dynoL, dynoR );

        if ( chooser.getInt( 1, 1 ) ) {
            fxManager.connect( loopFileBufs[i] );

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
    dur waitTime;

    while ( active ) {
        if ( chooser.takeAction( 3 ) ) {
            playSnd( oneShotBufs, files );
        }
        else {
            chooser.getWait( waitMin, waitMax ) => waitTime;
            waitTime => now;
        }
    }
}

fun void playSnd(SndBuf2 bufs[], string files[] ) {
    chooser.getInt( 0, bufs.cap() - 1 ) => int choice;
    Sample sample;

    chooser.takeAction( 3 ) => int fxOn;
    <<< "playing", files[choice] >>>;
    spork ~ sample.initialise(files[choice], bufs[choice], 0, 0.8, dynoL, dynoR );

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
