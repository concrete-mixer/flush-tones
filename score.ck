me.dir() => string path;

fun void initSample(string filepath, int loop, dur scheduleInterval ) {
    Sample sample;
    sample.initialise(filepath, 1 );
    ActionScheduler schedule;
    schedule.initialise(sample, scheduleInterval );
}

spork ~ initSample(path + "audio/santorini_cistern.wav", 1, 10::second );

// sampleTest();

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
    1::second => now;
}
