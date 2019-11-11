#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw(shuffle);
use Cwd;
use Data::Dumper;

open( my $fh, './config' ) or die "Cannot open config file";
my @config_rows = <$fh>;
my $config = {};
foreach my $row ( @config_rows ) {
    next if ( $row =~ /^#/ );

    my ( $key, $value ) = split( '=', $row );
    chomp $value;
    $config->{$key} = $value;
}

$config->{cwd} = cwd();
use Data::Dumper qw(Dumper);
print Dumper $ARGV[0];

if (!$ARGV[0]) {
    exit 'No audio path provided'
}

my @args = ($config->{path_to_chuck}, "main.ck:$ARGV[0]", '--srate44100');
system @args;
