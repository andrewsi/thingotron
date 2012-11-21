package Queue;

@ISA = qw (LinkedList);

##
# This is the class that creates a Queue, based off the LinkedList class.
# It's initially called with an optional array of values.
#
# This is on the list of Programming Constructs That May Never Be Used But I'm Coding Up Anyway For Practice
#
# A queue is a list of data; you add data to the top, and remove it from the bottom (First In, First Out)
# That's distinct from a stack, whish is Last In, First Out.
##

use strict;
use LinkedList;

sub new {
	## 
	# Constructor
	# Takes an optional reference to a list of entries to add to the queue on creation
	# Otherwise, creates an empty list
	#
	# I'm going to create the queue as a linked list. When we get new entries to add, they will need adding at the end 
	# of the list
	##

	my $class = shift;

	my $self = LinkedList->new();

	bless $self, $class;

	if (scalar(@_)) {
		$self->addNodes(shift);
	}

	return $self;
}

sub add {
	my $self = shift;
	my $data = shift;

	$self->addNodes($data);
}

sub remove {
	my $self = shift;

	return $self->deleteOneNode($self->{rootNode});
}

1;
