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

sub new {
	my $class = shift;

	my $config = shift;

	my $self = {};

	$self->{"api"} = $config->{"api"};

	bless $self, $class;

	return $self;
}

sub getUserDetails {
	my ($self, $username, @junk) = @_;

	my $theURL = "http://api.twitter.com/1/users/show.json?screen_name=" . $username;

	my $browser = LWP::UserAgent->new;

	my $response = $browser->get($theURL);

	return (from_json($response->{"_content"}));
}

1;
