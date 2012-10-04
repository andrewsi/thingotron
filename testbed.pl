#!perl;

use strict;
use LinkedList;

my @data = (1, 2, 3, 4, 5, 6);

my $list = new LinkedList(\@data);

my $node = $list->findNode(7);

print $node->getContents();

exit;
