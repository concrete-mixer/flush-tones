Dyno dyn => dac;

me.dir() => string path;

fun void init_sample(string filepath, int loop) {
    Sample sample;
    sample.initialise(filepath, 1);
    Scheduler schedule;
    schedule.schedule(sample);
}

spork ~ init_sample(path + "audio/santorini_cistern.wav", 1);


// keep things ticking over
while ( true ) {
    1::second => now;
}
