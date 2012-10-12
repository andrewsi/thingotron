package DataTree;

##
# This is a data tree storage class
# Nodes will get a 'higher' and 'lower' pointer; when you add a new node to this structure, we compare the values of this node
# with the new node, and place it accordingly.
#
# Has methods to add a new node; and to iterate through the structure
##

use Node;
use strict;

sub new {
	##
	# Constructor
	#
	# Doesn't take parameters, though that might change.
	##
	
	my $class = shift;

	my $self = { 
		rootNode => undef, 
		nodeNames => ["higher", "lower"],
	};

	bless $self, $class;

	return $self;
}

sub addItem {
	my $self = shift;
	my $data = shift;

	my $newNode = Node->new($data, $self->{nodeNames});

	my $addNode = $self->{rootNode};
	my $lastNode = undef;
	my $whichNode = "";

	while (defined($addNode)) {
		if ($addNode->getContents() < $newNode->getContents()) {
			$whichNode = "higher";
		} else {
			$whichNode = "lower";
		}
		$lastNode = $addNode;
		$addNode = $addNode->getNode($whichNode);
	}

	if (! defined($lastNode)) {
		$self->{rootNode} = $newNode;
	} else {
		$lastNode->setNode($whichNode, $newNode);
	}
}

sub walk {
	my $self = shift;

	my $startNode = $self->{rootNode};

	$self->treeWalk($startNode);
}

sub treeWalk {
	my $self = shift;
	my $startNode = shift;

	if (defined($startNode->getNode("lower"))) {
		$self->treeWalk($startNode->getNode("lower"));
	}
	print $startNode->getContents . "\n";

	if (defined($startNode->getNode("higher"))) {
		$self->treeWalk($startNode->getNode("higher"));
	}
}

1; 
