#!perl;

use strict;
use LoadConfig;
use Twitter;

my $config = new LoadConfig("C:\\Perl\\programs\\thingotron\\twitter.config");

my $twitter = new Twitter($config);

my $values = $twitter->getUserDetails($config->{"user"});

foreach my $entry (keys(%{$values})) {
	print $entry . "\t" . $values->{$entry} . "\n";
}

exit;
