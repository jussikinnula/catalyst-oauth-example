requires 'Catalyst::Runtime', '5.90015';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General';

on 'test' => sub {
    requires 'Test::More' => '0.88';
};

## Application dependencies
##
requires 'Net::Google::DataAPI::Auth::OAuth2';
requires 'WebService::Instagram';
requires 'Facebook::Graph';
requires 'Facebook::Graph::AccessToken';
requires 'Net::Google::DataAPI::Auth::OAuth2';
requires 'Data::Dumper';
requires 'Mozilla::CA';
