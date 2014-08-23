#!/usr/bin/env perl
use LWP::UserAgent;
use Mozilla::CA;

# Setting up user agent
my $ua = LWP::UserAgent->new();
$ua->agent("MyApp/0.1");
$ua->ssl_opts({
    verify_hostname => 1,
    SSL_ca_file => Mozilla::CA::SSL_ca_file(),
});

# Reading command line params
my $client_id = $ARGV[0];
my $client_secret = $ARGV[1];
my $refresh_token = $ARGV[2];

unless ($client_id && $client_secret && $refresh_token) {
    print "Usage:\n";
    print "worker/google_crawler.pl [client_id] [client_secret] [refresh_token]\n\n";
    exit;
}

# Get new access token each 30 minutes (rationale: Google OAuth access token is valid for 60 minutes)
while(1) {
    # Create a request
    my $oauth2 = HTTP::Request->new(POST => 'https://accounts.google.com/o/oauth2/token');
    $oauth2->content_type('application/x-www-form-urlencoded');
    my $params = "client_id=".$client_id."&".
                 "client_secret=".$client_secret."&".
                 "refresh_token=".$refresh_token."&".
                 "grant_type=refresh_token";
    $oauth2->content($params);
    # Pass request to the user agent and get a response back
    my $res = $ua->request($oauth2);

    # Check the outcome of the response
    if ($res->is_success) {
        print "OAuth2 Refresh success:\n";
        print $res->content;
        print "\n\n";
    } else {
        print "Ouch: ".$res->status_line."\n\n";
    }

    print "Sleeping for 30 minutes...\n\n";
    sleep(1800);

}
