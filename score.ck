me.dir() => string path;

fun void initSample(string filepath, int loop ) {
    Sample sample;
    sample.initialise(filepath, 1 );
    SampleController controller;
    controller.initialise( sample );
}

spork ~ initSample(path + "audio/santorini_cistern.wav", 1 );

// spork ~ sampleTest();

fun void sampleTest() {
    Sample sample;
    sample.initialise( path + "audio/santorini_cistern.wav", 1 );
    FxDelay delay;
    spork ~ delay.initialise();
    sample.connect( delay.inputL, delay.inputR );
    delay.outputL => dac.left;
    delay.outputR => dac.right;
    sample.changeFade( "in", 10::second );
}

// keep things ticking over
while ( true ) {
    5::second => now;
}
