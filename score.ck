me.dir() => string path;
Chooser chooser;

FxManager fxManager;
fxManager.initialise();

fun void initSample(string filepath, int loop, float vol ) {
    Sample sample;
    ActionFadeIn fadeIn;
    if ( chooser.getInt( 1, 1 ) ) {
        <<< "hurf" >>>;
        fxManager.connect( sample.out );
    }

    spork ~ sample.initialise(filepath, loop );
    fadeIn.execute( sample );
}

initSample(path + "audio/santorini_cistern.wav", 1, '0.7' );
initSample(path + "audio/drip-no-hum-full.wav", 1, '0.7' );
initSample(path + "audio/flush-short.wav", 0, '0.2' );

// keep things ticking over
while ( true ) {
    <<< "ping..." >>>;
    5::second => now;
}
