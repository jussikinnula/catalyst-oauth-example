package WebApp::Controller::Root;
use Moose;
use namespace::autoclean;
use WebService::Instagram;
use Facebook::Graph;
use Facebook::Graph::AccessToken;
use Net::Google::DataAPI::Auth::OAuth2;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

has google => ( is => 'rw', lazy => 1, builder => '_google' );
has instagram => ( is => 'rw', lazy => 1, builder => '_instagram' );
has facebook => ( is => 'rw', lazy => 1, builder => '_facebook' );
has redirect => ( is => 'rw', lazy => 1, builder => '_redirect' );

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub _redirect {
    my ( $self, $c ) = @_;
    my $redirect_uri = $ENV{'REDIRECT_URI'} || 'http://localhost:5000';
    return $redirect_uri;
}

# Instagram API token generation only. Request /instagram
sub _instagram {
    my ( $self, $c ) = @_;
    return WebService::Instagram->new({
        client_id => $ENV{'INSTAGRAM_CLIENT_ID'} || '',
        client_secret => $ENV{'INSTAGRAM_CLIENT_SECRET'} || '',
        redirect_uri => $self->redirect.'/instagram/inst',
    });
}

sub instagram_generatetokenid :Path('/instagram') :Args(0) {
    my ( $self, $c ) = @_;
    $c->res->redirect($self->instagram->get_auth_url());
    $c->detach();
}

sub instagram_inst :Path('/instagram/inst') :Args() {
    my ( $self, $c ) = @_;
    my $code = $c->req->param('code');
    if ( defined $code ) {
        $c->forward('instagram_gettoken', [ $code ] );
        $c->detach();
    }
    $c->res->body("Code not found");
}

sub instagram_gettoken :Path('/instagram/gettoken') :Args(1) {
    my ( $self, $c, $code ) = @_;
    $self->instagram->set_code($code);  
    my $access_token = $self->instagram->get_access_token();
    $c->res->body("access_token:".$access_token);
    $c->detach();
}

# Facebook API token generation only. Request /facebook
sub _facebook {
    my ( $self, $c ) = @_;
    return Facebook::Graph->new({
        app_id => $ENV{'FACEBOOK_APP_ID'} || '',
        secret => $ENV{'FACEBOOK_SECRET'} || '',
        postback => $self->redirect.'/facebook/postback',
    });
}

sub facebook_generatetokenid :Path('/facebook') :Args(0) {
    my ( $self, $c ) = @_;
    $c->res->redirect($self->facebook->authorize->extend_permissions(qw(offline_access))->uri_as_string);
    $c->detach();
}

sub facebook_inst :Path('/facebook/postback') :Args() {
    my ( $self, $c ) = @_;
    my $code = $c->req->param('code');
    if ( defined $code ) {
        $c->forward('facebook_gettoken', [ $code ] );
        $c->detach();
    }
    $c->res->body("Code not found");
}

sub facebook_gettoken :Path('/facebook/gettoken') :Args(1) {
    my ( $self, $c, $code ) = @_;
    my $token = $self->facebook->request_access_token($code);
    $self->facebook->request_extended_access_token;
    $c->res->body("access_token:".$token->token."\nexpires:".$token->expires);
    $c->detach();
}

# Google API token generation only. Request /google
sub _google {
    my ( $self, $c ) = @_;
    return Net::Google::DataAPI::Auth::OAuth2->new({
        client_id => $ENV{'GOOGLE_CLIENT_ID'} || '',
        client_secret => $ENV{'GOOGLE_CLIENT_SECRET'} || '',
        scope => ['https://www.google.com/calendar/feeds/'],
        redirect_uri => $self->redirect.'/google/inst',
    });
}

sub google_generatetokenid :Path('/google') :Args(0) {
    my ( $self, $c ) = @_;
    $c->res->redirect($self->google->authorize_url());
    $c->detach();
}

sub google_inst :Path('/google/inst') :Args() {
    my ( $self, $c ) = @_;
    my $code = $c->req->param('code');
    if ( defined $code ) {
        $c->forward('google_gettoken', [ $code ] );
        $c->detach();
    }
    $c->res->body("Code not found");
}

sub google_gettoken :Path('/google/gettoken') :Args(1) {
    my ( $self, $c, $code ) = @_;
    my $access_token = $self->google->get_access_token($code);
    print Dumper $access_token;
    $c->res->body("access_token:".$access_token->{NOA_access_token});
    $c->detach();
}

sub end : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

1;
