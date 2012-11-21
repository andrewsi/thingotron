package Square;

use strict;

sub new {
	## Constructor
	# Takes an optional number
	# If the number is set, then that number is this square's initial value
	# We're going to store a hash of possible values. If there's just one value in there, then this square
	# is solved.
	##
	
	my $class = shift;

	my $self = {};

	bless $self, $class;

	# If we have a value passed in, use that as the single value for this Square. Otherwise, it's 
	# going to get numbers from 1 to 9

	if (scalar(@_)) {
		$self->{shift()} = 1;
	} else {
		for (my $i = 1; $i <= 9; $i++) {
			$self->{$i} = 1;
		}
	}

	return $self;
}

sub isSolved {
	##
	# If this square is solved, it has just one number left in the hash
	# If so, return that number.
	# Otherwise, return 0
	## 

	my $self = shift;

	my @values = keys(%{$self});

	if (scalar(@values) == 1) {
		return $values[0];
	} else {
		return 0;
	}
}

sub isPossibleValue {
	##
	# Check to see if this square could still contain this number; return 1 on success
	##

	my $self = shift;
	my $value = shift;

	if (exists($self->{$value})) {
		return 1;
	}

	return 0;
}

sub setValue {
	##
	# Set the value of this square
	# (I'm doing this by deleting all the others; there's probably a more efficient way)
	##

	my $self = shift;
	my $value = shift;

	foreach my $key (keys(%{$self})) {
		if ($value != $key) {
			delete($self->{$key});
		}
	}
}

sub removeFromList {
	##
	# Try to remove a number from the list
	# If the number can be removed, remove it and return 1; otherwise, return 0
	# (This saves me having to make an extra call to isPossibleValue to see if it's there first)
	##

	my $self = shift;
	my $value = shift;

	if (exists($self->{$value})) {
		delete($self->{$value});
		return 1;
	}

	return 0;
}

sub getValues {
	##
	# Return an array containing the possible values for this square
	##

	my $self = shift;

	return keys(%{$self});
}

1;
