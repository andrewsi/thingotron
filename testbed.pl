#!perl

use strict;
use Grid;

my $puzzle = new Grid();
$puzzle->loadFile("data\\in.txt");
$puzzle->printGrid();
$puzzle->solve();
$puzzle->printGrid();

exit;
