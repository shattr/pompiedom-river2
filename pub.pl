# Copyright (C) 2012 Peter Stuifzand
# Copyright (c) 2012 Other contributors as noted in the AUTHORS file
#
# This file is part of Pompiedom River2
# Pompiedom River2 is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Pompiedom River2 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

