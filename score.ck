me.dir() => string path;
Chooser chooser;

FxManager fxManager;
fxManager.initialise();

fun void initSample(string filepath, int loop, float gain ) {
    Sample sample;
    ActionFadeIn fadeIn;
    if ( chooser.getInt( 1, 1 ) ) {
        <<< "hurf" >>>;
        fxManager.connect( sample.out );
    }

    spork ~ sample.initialise( filepath, loop, gain );
    fadeIn.execute( sample );
}

initSample(path + "audio/santorini_cistern.wav", 1, 0.7 );
initSample(path + "audio/drip-no-hum-full.wav", 1, 0.7 );
initSample(path + "audio/flush-short.wav", 0, 0.2 );

[
    path + "audio/tuba/2748_tuba_023_5_7_1.mp3.wav",
    path + "audio/tuba/2513_tuba_043_4_5_1.mp3.wav",
    path + "audio/bassoon/2166_bassoon_036_4_7_1.mp3.wav",
    path + "audio/bassoon/2385_bassoon_077_2_7_1.mp3.wav",
    path + "audio/saxophone/1390_saxophone_057_2_9_1.mp3.wav",
    path + "audio/saxophone/1811_saxophone_067_3_6_1.mp3.wav"
] @=> string filesList[];

WaveBank bank;
bank.initialise(filesList);

class WaveBank {
    6 => int selCount;
    Chooser chooser;
    Pan2 pan => dac;
    string selectedWaves[selCount];

    fun void initialise( string files[] ) {
        int choices[selCount];
        0 => int selectionsMade;

        while ( selectionsMade < selCount ) {
            chooser.getInt( 0, selCount - 1 ) => int choice;
            <<< "choice", choice >>>;
            <<< "files", files[choice] >>>;
            0 => int alreadyChosen;

            for ( 0 => int j; j < choices.cap() -1; j++ ) {
                <<< "choices[", j, "]", choices[j] >>>;
                if ( choices[j] == choice ) {
                    1 => alreadyChosen;
                }
            }

            <<< "already chosen", alreadyChosen >>>;
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
            dur waitTime;
            if ( chooser.takeAction( 2 ) ) {
                playSnd() => waitTime;
            }
            else {
                chooser.getWait( 3, 5 ) => waitTime;
            }
            <<< "passing time", waitTime / 44100 >>>;
            waitTime => now;
        }
    }

    fun dur playSnd() {
        chooser.getInt( 0, selCount - 1 ) => int choice;
        SndBuf buf => pan;
        0.5 => buf.gain;
        selectedWaves[choice] => buf.read;
        // <<< "choice", selectedWaves[choice] >>>;
        // reverse now and then
        if ( chooser.takeAction( 3 ) ) {
            -1.0 => buf.rate;
        }

        if ( chooser.takeAction( 2 ) ) {
            <<< "fx!" >>>;
            buf => fxManager.connect;
        }

        chooser.getFloat( -1.0, 1.0 ) => pan.pan;
        return buf.length();
    }
}



// keep things ticking over
while ( true ) {
    <<< "ping..." >>>;
    5::second => now;
}
