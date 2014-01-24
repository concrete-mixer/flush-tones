public class WaveBank {
    Chooser chooser;
    1 => int selCount;
    string selectedWaves[];
    float waitMin;
    float waitMax;
    UGen outputL;
    UGen outputR;
    FxManager fxManager;

    fun void initialise( string inputWaves[], FxManager inputFxManager, UGen inputOutputL, UGen inputOutputR, float inputWaitMin, float inputWaitMax ) {
        inputFxManager @=> fxManager;
        inputOutputL @=> outputL;
        inputOutputR @=> outputR;
        inputWaitMin => waitMin;
        inputWaitMax => waitMax;
        inputWaves @=> selectedWaves;
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
                chooser.getWait( waitMin, waitMax ) => waitTime;
                <<< "passing time", waitTime / 44100 >>>;
                waitTime => now;
            }
        }
    }

    fun dur playSnd() {
        chooser.getInt( 0, selectedWaves.cap() - 1 ) => int choice;
        <<< "playing sound", choice, selectedWaves[choice] >>>;
        SndBuf buf => Pan2 pan;
        pan.left => outputL;
        pan.right => outputR;
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
        pan.left =< outputL;
        pan.right =< outputR;
        <<< "no longer playing sound" >>>;

        if ( fxOn ) {
            buf => fxManager.disconnect;
        }
    }
}

