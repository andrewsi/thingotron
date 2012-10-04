package LinkedList;

##
# This is the class that works with setting up the list
# It's initially called with an array of values; those are 
# each added to the List using LinkedListNode's constructor, 
##

# Things that I could do with adding:
#
# Merge two lists
# Proper comparisons and search code - pass in references to functions to compare?
# Add item at start of list
# Better delete list - step through the list, get next node, undef this one?
#

use LinkedListNode;
use strict;

sub new {
	##
	# Constructor
	# Takes an optional list of entries to put into the list on creation.
	# If there's no list, then it creates an empty list
	#
	# There are two elements to work with:
	# - root points at the first node of the list
	# - length counts how many nodes are in the list
	##

	my $class = shift;

	my $self = {
		root => undef,
		length => 0, 
	};

	bless $self, $class;

	if (scalar(@_)) {
		##
		# If we have data passed in, then pass it into addNodes to create the list
		##
		my $data = shift;
		$self->addNodes($data);
	}

	return $self; 
}

sub getLength {
	##
	# Return the current length of the list
	##
	my $self = shift;

	return $self->{length};
}

sub iterate {
	## 
	# Step through this list, one item at a time, and print out the contents of the node.
	##
	my ($self) = @_;

	my $thisNode = $self->{root};

	if (defined($thisNode)) { 
		while (defined($thisNode)) {
			print $thisNode->getContents() . "\n";
			$thisNode = $thisNode->getNextNode();
		}
	}
}

sub iterateBackwards {
	##
	# Step through this list, one item at a time, starting from the last node and working forwards.
	##
	my ($self) = @_;

	my $thisNode = $self->moveToNode();

	if (defined($thisNode)) {
		while (defined($thisNode)) {
			print $thisNode->getContents() . "\n";
			$thisNode = $thisNode->getPreviousNode();
		}
	}
}

sub moveToNode {
	##
	# Move to a specific node in the list
	# 
	# This takes an optional parameter; if there's one given, then we move to that item in the list
	# This is 0-indexed, so to move to the first item, you need to pass in 0
	# If there's no parameter entered, then we'll go to the final node in the list
	#
	# If you pass in an index that's higher than the 
	##
	my $self = shift;

	# $nodeIndex is, effectively, the number of steps through this list we want to take.
	# Its default value is the length of the array, minus 1 (we're only going to need to take 5 steps to get 
	# to the end of a 6-node array); it's over-written by the optional parameter
	my $nodeIndex = $self->{length} - 1;

	if (scalar(@_)) {
		$nodeIndex = shift;

		if ($nodeIndex >= $self->{length}) {
			$nodeIndex = $self->{length} - 1;
		}
	}

	## Start out with the first node
	my $thisNode = $self->{root};
	while ((defined($thisNode)) && ($nodeIndex > 0)) {
		## While we have more nodes to examine, and nodeIndex is above 0, move $thisNode to the next node in the list
		# and decrement $nodeIdex

		$thisNode = $thisNode->getNextNode();
		$nodeIndex--;
	}

	return $thisNode;
}

sub addNodes {
	##
	# Add one or more new nodes to the list
	#
	# This takes the data as a parameter - this is a reference to an array of values to add into the list
	# You can also add in an optional parameter, which is the node number after which to add the data
	##

	my $self = shift;
	my $data = shift;

	my $lastNode = undef;
	my $nodeCount = 0;

	if (scalar(@_)) {
		$lastNode = shift;
	} else {
		$lastNode = $self->moveToNode();
	}

	foreach my $item (@$data) {
		## Firstly, create the new node
		my $newNode = LinkedListNode->new($item);

		## Now, we need to add it to the list.
		# If it's not the first node, then we need to update the pointers for the neighbouring nodes:
		# The previousNode pointer for the next node; and the nextNode pointer for the previous node point at this node
		# This node's previousNode pointer and nextNode pointer also need setting

		if (defined($lastNode)) {
			## This isn't the first node, so we need to update pointers

			if (defined($lastNode->getNextNode())) {
				## The previous node has a nextNode set. In that case, we're inserting this between two 
				# existing nodes. So we need to point their Next and Previous pointers to point at the 
				# new node
				##

				$lastNode->getNextNode->setPreviousNode($newNode);
				$newNode->setNextNode($lastNode->getNextNode());
			}

			##
			# Finally, set the pointers on this node to the right place
			##

			$lastNode->setNextNode($newNode);
			$newNode->setPreviousNode($lastNode);
		} else {
			##
			# This is the first node in the list
			# So update $self to point to this node as root
			## 
			$self->{root} = $newNode;
		}

		$lastNode = $newNode;
		$nodeCount++;
	}

	##
	# Make sure that length is incremented by the number of nodes we've added
	##

	$self->{length} += $nodeCount;
}

sub deleteOneNode {
	##
	# Remove one node from the list
	##

	my $self = shift;
	my $node = shift;

	## 
	# Get this node's next and previous pointers.
	# If they're set, then redirect them to the right place
	##

	my $prev = $node->getPreviousNode();
	my $next = $node->getNextNode();

	if (defined($prev)) {
		$prev->setNextNode($next);
	}
	if (defined($next)) {
		$next->setPreviousNode($prev);
	}

	##
	# If this is the root node, then point it at what was the second node
	##

	if ($node == $self->{root}) {
		$self->{root} = $next; 
	}

	##
	# decrement the length of the list by one
	## 

	$self->{length}--;

	##
	# Finally, return the contents of the deleted node.
	# There's no need for this function to return anything, but it might as well pass the value back
	##
	
	my $contents = $node->getContents();
	$node = undef;

	return $contents;
}

sub deleteList {
	##
	# Delete a whole list
	#
	# I could probably just re-set $self, but if I call deleteOneNode, it'll clean everything up properly.
	#
	# There's almost certainly better ways of doing this - this will re-index the list after deleting each node, 
	# which is probably overkill if we're deleting everything.
	##

	my $self = shift;

	while ($self->{length} > 0) {
		$self->deleteOneNode($self->{root});
	}
}

sub findNode {
	##
	# Fine one node in the list, based on its contents
	#
	# This will return the node, or undef if there's no match
	##
	my $self = shift;
	my $value = shift;

	my $checkNode = $self->{root};

	while ((defined($checkNode)) && ($value ne $checkNode->getContents())) {
		$checkNode = $checkNode->getNextNode();
	}

	return $checkNode; 
}

1;
