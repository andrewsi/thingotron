#!perl

use strict;
use Grid;

my $puzzle = new Grid("data\\in3.txt");
$puzzle->printGrid();
$puzzle->solve();
$puzzle->printGrid();

exit;
