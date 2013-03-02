#!perl

use strict;
use Utility::CSV;

my $csv = new CSV();
$csv->filename("./test.csv");

my $lines = $csv->loadfile();

$csv->writefile($lines);

exit;
