#!perl;

use strict;
use LoadConfig;
use Twitter;

my $config = new LoadConfig("C:\\Perl\\programs\\thingotron\\twitter.config");

my $twitter = new Twitter($config);

$twitter->tweet("Hello, world");

exit;
