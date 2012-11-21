package Stack;

@ISA = qw (LinkedList);

##
# This is the class that creates a Stack, based off the LinkedList class.
# It's initially called with an optional array of values
#
# This is on the list of Programming Constructs That May Never Be Used But I'm Coding Up Anyway For Practice
#
# A stack is a list of data; you add data to the top, and remove it from the same place (Last In First Out)
# That's distinct from a queue, which is First In, First Out.
##

use strict;
use LinkedList;

sub new {
	##
	# Constructor
	# Takes an optional reference to a list of entries to add to the stack on creation
	# Otherwise, creates an empty stack
	#
	# I'm going to create the stack as a linked list. When we get new entries to add, they will need adding at the start of the list
	# (Remember, if there are multiple entries, we need to step through the list and add each of them to the top of the stack in turn, 
	# so 1,2,3 will end up on the stack as 3,2,1)
	##

	my $class = shift;

	my $self = LinkedList->new();

	bless $self, $class;

	if (scalar(@_)) {
		##
		# If we have data passed in, pass it to addToStart
		##

		$self->add(shift);
	}

	return $self;
}

sub add {
	my $self = shift;
	my $data = shift;

	foreach my $thisData (@$data) {
		$self->addNodeToStart($thisData);
	}
}

sub remove {
	my $self = shift;

	my $node = $self->{rootNode};

	return $self->deleteOneNode($node);
}

1;
