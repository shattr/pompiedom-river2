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

package Pompiedom::Plack::Middleware::CORS;
use strict;
use parent 'Plack::Middleware';
use Data::Dumper;

use Plack::Util;

sub call {
    my $self = shift;
    my $env = shift;

    my $res = $self->app->($env);

    return Plack::Util::response_cb($res, sub {
        my $res = shift;
        Plack::Util::header_push($res->[1], 'Access-Control-Allow-Origin', '*');
        return $res;
    });
}

1;
