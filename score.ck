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

initSample(path + "audio/santorini_cistern.wav", 1, 0.5, dynoL, dynoR );
initSample(path + "audio/drip-no-hum-full2.wav", 1, 0.5, dynoL, dynoR );
// initSample(path + "audio/drip-hum-sub2.wav", 1, 0.5, dynoL, dynoR );

[
    path + "audio/tuba/2748_tuba_023_5_7_1.mp3.wav",
    path + "audio/tuba/2513_tuba_043_4_5_1.mp3.wav",
    path + "audio/bassoon/2166_bassoon_036_4_7_1.mp3.wav",
    path + "audio/bassoon/2385_bassoon_077_2_7_1.mp3.wav",
    path + "audio/saxophone/1390_saxophone_057_2_9_1.mp3.wav",
    path + "audio/saxophone/1811_saxophone_067_3_6_1.mp3.wav",
    path + "audio/flush2-short.wav"
] @=> string filesList[];

WaveBank bank;
bank.initialise(filesList);

class WaveBank {
    6 => int selCount;
    Chooser chooser;
    string selectedWaves[selCount];

    fun void initialise( string files[] ) {
        int choices[selCount];
        0 => int selectionsMade;

        while ( selectionsMade < selCount ) {
            chooser.getInt( 0, selCount - 1 ) => int choice;
            0 => int alreadyChosen;

            for ( 0 => int j; j < choices.cap() -1; j++ ) {
                if ( choices[j] == choice ) {
                    1 => alreadyChosen;
                }
            }

            if ( ! alreadyChosen ) {
                files[choice] => selectedWaves[selectionsMade];
                choice => choices[selectionsMade];
                selectionsMade++;
            }
        }

        printSounds();
        schedule();
    }

    fun void printSounds() {
        0 => int i;

        while( i < selectedWaves.cap() ) {
            <<< "file:", selectedWaves[i] >>>;
            i++;
        }
    }

    // plan here is generate a random sequence of samples
    fun void schedule() {
        while ( true ) {
            if ( chooser.takeAction( 2 ) ) {
                playSnd();
            }
            else {
                dur waitTime;
                chooser.getWait( 3, 5 ) => waitTime;
                <<< "passing time", waitTime / 44100 >>>;
                waitTime => now;
            }
        }
    }

    fun dur playSnd() {
        <<< "playing sound" >>>;
        chooser.getInt( 0, selCount - 1 ) => int choice;
        SndBuf buf => Pan2 pan;
        pan.left => dynoL;
        pan.right => dynoR;
        0.5 => buf.gain;
        selectedWaves[choice] => buf.read;
        // <<< "choice", selectedWaves[choice] >>>;
        // reverse now and then
        if ( chooser.takeAction( 3 ) ) {
            <<< "reversing" >>>;
            -1.0 => buf.rate;
        }

        chooser.takeAction( 2 ) => int fxOn;

        if ( fxOn ) {
            <<< "fx!" >>>;
            buf => fxManager.connect;
        }

        chooser.getFloat( -1.0, 1.0 ) => pan.pan;
        <<< "pan:", pan.pan() >>>;
        buf.length() => now;

        buf =< pan;
        pan.left =< dynoL;
        pan.right =< dynoR;
        <<< "no longer playing sound" >>>;

        if ( fxOn ) {
            buf => fxManager.disconnect;
        }
    }
}



// keep things ticking over
while ( true ) {
    <<< "ping..." >>>;
    5::second => now;
}
