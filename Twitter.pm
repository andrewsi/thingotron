package Twitter;

##
# Provide a wrapper around Twitter API functions
#
# Requires a config file passing in with the details of the connection to use
##

use strict;
use Win32::API;

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

	return ();
}

1;
