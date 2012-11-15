#!perl

use strict;
use Grid;

my $puzzle = new Grid("data\\in45.txt");
$puzzle->printGrid();
$puzzle->solve();
$puzzle->printGrid();

exit;
