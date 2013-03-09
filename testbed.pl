#!perl

use strict;
use Utility::CSV;

my $csv = new CSV();
$csv->filename("./test.csv");

my $lines = $csv->loadfile();

if (! $lines) {
	print $csv->error();
}

$csv->writefile($lines);

exit;
