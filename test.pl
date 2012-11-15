#!perl

use strict;
use CGI;
use URI::Escape;
use CGI::Simple;
use CGI::Simple::Util;

my $char = "å";

print CGI::escape($char) . "\n";
	print URI::Escape::uri_escape_utf8($char) . "\n";
print CGI::Simple->url_encode($char) . "\n";
print CGI::Simple::Util::escape($char) . "\n";

exit;
