#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use ComXo::Call2;

plan skip_all => "ENV CALL2_ACCOUNT/CALL2_PASSWORD/CALL2_FROM/CALL2_TO is required to continue."
    unless ($ENV{CALL2_ACCOUNT} and $ENV{CALL2_PASSWORD} and $ENV{CALL2_FROM} and $ENV{CALL2_TO});

my $call2 = ComXo::Call2->new(
    account  => $ENV{CALL2_ACCOUNT},
    password => $ENV{CALL2_PASSWORD},
    debug    => 1,
);

my $call_id = $call2->InitCall(
    bnumber  => $ENV{CALL2_FROM},
    anumber  => $ENV{CALL2_TO},
    alias    => 'FixedOdds',
) or die $call2->errstr;
diag("Get call_id as $call_id");
ok($call_id > 0); # 15387787

done_testing();

1;