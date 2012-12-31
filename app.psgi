use 5.10.1;
use strict;

use Carp;
use Plack::Builder;
use Plack::App::File;
use PocketIO;
use File::Slurp 'read_file';
use AnyEvent;
use Data::Dumper;
BEGIN {
    $ENV{ZMQ_PERL_BACKEND} = 'ZMQ::LibZMQ3';
}
use ZMQ;
use ZMQ::Constants qw/:all/;

my $root = '/home/peter/work/pompiedom-river2/static/socket.io';

my %connections;

sub random_key {
    my @chars = 'A'..'Z';
    my $key = '';
    for (1..8) {
        $key .= $chars[int rand(@chars)];
    }
    return $key;
}

my $ctx = ZMQ::Context->new(1);

my $sub = $ctx->socket(ZMQ_SUB);
$sub->setsockopt(ZMQ_SUBSCRIBE, '');
$sub->bind('tcp://127.0.0.1:5959');

our $w = AE::io(
    $sub->getsockopt(ZMQ_FD), 0, sub {
        while (my $msg = $sub->recvmsg(ZMQ_NOBLOCK)) {
            eval {
                my $data = $msg->data;
                say $data;
                $msg->close;

                for my $socket (values %connections) {
                    $socket->send($data);
                }
            };
        }
        return;
    },
);

builder {
    mount "/socket.io/socket.io.js" => Plack::App::File->new(file => "$root/socket.io.js");
    mount '/socket.io/static/flashsocket/WebSocketMain.swf' => Plack::App::File->new(file => "$root/WebSocketMain.swf");
    mount '/socket.io/static/flashsocket/WebSocketMainInsecure.swf' => Plack::App::File->new(file => "$root/WebSocketMainInsecure.swf");

    mount "/socket.io" => PocketIO->new(
        handler => sub {
            my $self = shift;

            my $k = random_key();

            $self->set('key', $k);
            $connections{$k} = $self;

            $self->send({key => $k});

            $self->on('disconnect', sub {
                my $self = shift;
                $self->get('key', sub {
                    my ($err, $key) = @_;
                    delete $connections{$key};
                });
            });
            return;
        }
    );

    enable "Static", path => sub { s!^/static/!! }, root => 'static';

    mount '/' => sub {
        return [ 200, [], [ read_file('templates/index.tt') ] ];
    };
};

