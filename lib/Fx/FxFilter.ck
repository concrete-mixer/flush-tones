class FxFilter extends Fx {
    FilterBasic filter;
    Chooser chooser;
    LFO lfo;

    chooser.getInt( 0, 2 ) => int typeChoice;

    if ( typeChoice == 0 ) {
        LPF lpf @=> filter;
    }

    if ( typeChoice == 1 ) {
        HPF hpf @=> filter;
    }

    if ( typeChoice == 2 ) {
        BPF bpf @=> filter;
    }

    input => filter => output;

    if ( chooser.getInt( 0, 1 ) ) {
        while ( 1 ) {
            lfo.
        }
    }


}
