use strict;
use warnings;
use lib 'lib';
use WebApp;
use Plack::Builder;

my $app = WebApp->psgi_app;

builder {
    enable 'ReverseProxy';
    enable 'ConditionalGET';
    $app;
};

