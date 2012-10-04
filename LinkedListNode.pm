package LinkedListNode;

##
# This is the class that contains the nodes for a linked list.
# If it's to do with manipulating the data in one node, it goes in here.
# This is where you set up the nodes, and query their data
##

use strict;

sub new {
	my $class = shift;

	my $contents = shift;

	my $self = {
		nextNode 	=> undef,
		previousNode	=> undef,
		contents	=> $contents,
	};

	bless $self, $class;
	return $self;
}

sub setNextNode {
	my ($self, $nextNode) = @_;

	$self->{nextNode} = $nextNode;
}

sub setPreviousNode {
	my ($self, $previousNode) = @_;

	$self->{previousNode} = $previousNode;
}

sub getNextNode {
	my $self = shift;
	return $self->{nextNode};
}

sub getPreviousNode {
	my $self = shift;
	return $self->{previousNode};
}

sub getReferenceID {
	my $self = shift;
	return $self->{referenceID};
}

sub getContents {
	my $self = shift;
	return $self->{contents};
}

1;
