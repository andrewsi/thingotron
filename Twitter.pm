package Twitter;

##
# Provide a wrapper around Twitter API functions
#
# Requires a config file passing in with the details of the connection to use
#
# Read-only APIs:
# *	need to be authenticated
# USER
# - account/settings		*
# - account/verify_credentials	(check authentication)
# - blocks/list			*
# - blocks/ids			*
# - users/lookup		(takes comma separated user_id or screen_name list)
# - users/show
# - users/search
# - users/contributees
# - users/contributors
##

use strict;
use LWP;
use JSON;
use URI::Escape;
use MIME::Base64 qw(encode_base64);
use Digest::HMAC_SHA1;

sub new {
	my $class = shift;

	my $config = shift;

	my $self = {};

	$self->{"consumerKey"} = $config->{"consumerKey"};
	$self->{"consumerSecret"} = $config->{"consumerSecret"};
	$self->{"accessToken"} = $config->{"accessToken"};
	$self->{"accessTokenSecret"} = $config->{"accessTokenSecret"};

	$self->{"rootURL"} = "https://api.twitter.com/1.1/";

	bless $self, $class;

	return $self;
}

sub getUserDetails {
	my ($self, $username, @junk) = @_;

	my $theURL = $self->{"rootURL"} . "users/show.json?screen_name=" . $username;

	my $browser = LWP::UserAgent->new;

	my $response = $browser->get($theURL);

	return (from_json($response->{"_content"}));
}

sub tweet {
	my ($self, $status, @junk) = @_;

	my $theURL = $self->{"rootURL"} . "statuses/update.json";

	my %parameters = ();

	$parameters{"oauth_consumer_key"} = $self->{"consumerKey"};
	$parameters{"oauth_nonce"} = time();
	$parameters{"oauth_signature_method"} = "HMAC-SHA1";
	$parameters{"oauth_timestamp"} = time();
	$parameters{"oauth_token"} = $self->{"accessToken"};
	$parameters{"oauth_version"} = "1.0"; 
	$parameters{"status"} = $status;

	my $escapedString = doEncoding(%parameters);

	my $baseString = "";

	$baseString = "POST&";
	$baseString .= URI::Escape::uri_escape_utf8($theURL) . "&";
	$baseString .= URI::Escape::uri_escape_utf8($escapedString);

	my $signingKey = "";

	$signingKey = URI::Escape::uri_escape_utf8($self->{"consumerSecret"}) . "&";
	$signingKey .= URI::Escape::uri_escape_utf8($self->{"accessTokenSecret"});

	$parameters{"oauth_signature"} = URI::Escape::uri_escape_utf8(hmac_encode ($signingKey, $baseString));

	my $authorization = "OAuth ";
	$authorization .= 'oauth_consumer_key="' . $parameters{"oauth_consumer_key"} . '", ';
	$authorization .= 'oauth_nonce="' . $parameters{"oauth_nonce"} . '", ';
	$authorization .= 'oauth_signature="' . $parameters{"oauth_signature"} . '", ';
	$authorization .= 'oauth_signature_method="' . $parameters{"oauth_signature_method"} . '", ';
	$authorization .= 'oauth_timestamp="' . $parameters{"oauth_timestamp"} . '", ';
	$authorization .= 'oauth_token="' . $parameters{"oauth_token"} . '", ';
	$authorization .= 'oauth_version="' . $parameters{"oauth_version"} . '"';

	my $browser = LWP::UserAgent->new;

	my $response = $browser->post($theURL . "?status=" . URI::Escape::uri_escape_utf8($status),
		"Authorization" => $authorization, 
		"Content-type" => "application/x-www-form-urlencoded");

	if ($response->is_success) {
		print "Success!";
	} else {
		print "Oooops";
	}

	print $response->status_line . "\n";
	print $response->decoded_content . "\n";
}

sub doEncoding {
	my %parameters = @_;

	my %escapedParameters = ();

	foreach my $key (keys(%parameters)) {
		$escapedParameters{URI::Escape::uri_escape_utf8($key)} = URI::Escape::uri_escape_utf8($parameters{$key});
	}

	my @retVal = ();

	foreach my $key (sort(keys(%escapedParameters))) {
		push (@retVal, $key . "=" . $escapedParameters{$key});
	}

	return (join('&', @retVal));
}

sub hmac_encode {
	my ($secret, $str, @junk) = @_;

	my $hmac = Digest::HMAC_SHA1->new($secret);
	$hmac->add($str);
	my $digest = $hmac->digest;

	my $base64 = encode_base64($digest, '');

	return $base64;
}

1;
