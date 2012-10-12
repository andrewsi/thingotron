package Node;

##
# This is the class that deals with creating nodes.
# It's a more generalized version of LinkedListNode - it's using a hash 
# to store the details of linked nodes, so you can add as many links as you
# want to. A linked list node will have two linked nodes (next and previous), 
# a search tree will have two (higher and lower), and so on
##

use strict;

sub new {
	my $class = shift;

	my $contents = shift;

	my $self = {
		contents	=> $contents,
		nodes		=> {}, 
	};

	while (my $nodeName = shift) {
		$self->{nodes}->{$nodeName} = undef;
	}

	bless $self, $class;
	return $self;
}

sub setNode {
	my ($self, $nodeName, $node) = @_;

	$self->{nodes}->{$nodeName} = $node;
}

sub getNode {
	my ($self, $nodeName) = @_;

	return $self->{nodes}->{$nodeName};
}

sub getContents {
	my $self = shift;

	return $self->{contents};
}

1;
