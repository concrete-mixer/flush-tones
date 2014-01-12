me.dir() => string path;

fun void initSample(string filepath, int loop ) {
    Sample sample;
    sample.initialise(filepath, loop );
    SampleController controller;
    controller.initialise( sample );
}

spork ~ initSample(path + "audio/santorini_cistern.wav", 1 );
20::second => now;
spork ~ initSample(path + "audio/drip-no-hum-full.wav", 1 );
20::second => now;
spork ~ initSample(path + "audio/flush-short.wav", 0 );

// spork ~ sampleTest();

fun void sampleTest() {
    Sample sample;
    sample.initialise( path + "audio/santorini_cistern.wav", 1 );
    FxDelay delay;
    spork ~ delay.initialise();
    sample.connect( delay.input );
    delay.output => dac;
    sample.changeFade( "in", 10::second );
}

// keep things ticking over
while ( true ) {
    5::second => now;
}
