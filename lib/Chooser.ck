/*
    Class to manage waiting, doing something, and doing nothing
*/
public class Chooser {
    /*
        takeAction returns true based on random choice
        Takes argument denominator, which is the end limit of the range of numbers
        a random value is chosen from.

        The function only returns true (1) if the random value chosen is 1. Therefore
        the denominator defines how often we expect to get a non zero result. This
        enables us to fine tune the frequency of activity from different sound
        manipulations.
    */
    fun static int takeAction(int denominator) {
        // plan here is to return 1 (true, do something, 10% of the time)
        Math.random2(1,denominator) => int choice;

        if ( choice == 1 ) {
            return 1;
        }

        return 0;
    }

    // wait just calls getDur; it's defined to disambiguate
    // calls for the purpose of determining durations of idleness
    // vs calls made to get a dur to do something with
    fun static dur wait( float min, float max ) {
        return getDur( min, max );
    }

    fun static dur getDur( float min, float max ) {
        return Math.random2f( min, max )::second;
    }


    // takes care of generating random floats, which we seem
    // to need a lot of
    fun static float getRandFloat( float min, float max ) {
        return Std.rand2f( min, max );
    }
}

