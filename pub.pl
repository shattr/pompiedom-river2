#!/usr/bin/env perl

use 5.10.1;
use strict;
use Data::Dumper;
use Time::HiRes 'sleep';

BEGIN {
    $ENV{ZMQ_PERL_BACKEND} = 'ZMQ::LibZMQ3';
}
use ZMQ;
use ZMQ::Constants qw/:all/;


my $ctx = ZMQ::Context->new(1);

my $poller = ZMQ::Poller->new;

my $pub = $ctx->socket(ZMQ_PUB);
$pub->connect('tcp://127.0.0.1:5959');

sleep 1;

$poller->register($pub, ZMQ_POLLOUT);

my $n = 0;

POLL: for (;;) {
    my @f = $poller->poll(1000);
    say scalar @f;

    for (@f) {
        $_->{socket}->sendmsg("test " . $n);
        sleep 1;
        $n++;
    }
}


