package Grid;

##
# This is the class that stores the whole grid
#
# It's a fairly basic solver, and won't finish tricky grids. 
#
# The theory is this. Every square is either solved, or not. An unsolved square has a number of possible values, based on the 
# squares around it - it can't share the same value with a square on the same row, column, or in the same house.
#
# The grid is created as an array of hashes - the hashes store the possible values for this square. If the square is solved, 
# there's only one possible value it can hold. As we build the grid, we find some solved squares. For each of these, go through 
# the squares on the same row, column, and house and remove this value from all the other squares (well, the ones where it might 
# still be a possibility); then, add those squares to the list to be re-checked
#
# At the end of this, we'll have a list of squares that need to be checked. We then run through that list - if a square is solved, 
# remove its value from the other squares in range, and if we make any changes, add those squares to the checking list if they're not 
# already there. 
#
# We cycle through the list to check - when it runs out, we've run out of basic checks that we can make.
#
# Look for singletons - check each (row / column / house) and see if there's a number that appears in just one square. If there is, 
# we can solve that square.
#
# Look for groups - if we have three squares, with possible values of (1,2,3), (1,2), (1,2), then the first square has to have a 
# value of 3
## 

use strict;
use Square;

sub new {
	my $class = shift;

	## 
	# We're going to store a set of Square classes in a 9x9 array, stores as:
	# $self->{row}->{column}
	# We'll also store:
	# coords - a list of squares that we need to check
	# solved - the number of squares that we've solved already
	##

	my $self = {};

	bless $self, $class;

	$self->{"coords"} = [];
	$self->{"solved"} = {};

	##
	# Start out by creating an empty grid, with no numbers set
	# Also add each square to the 'to be checked' list
	##

	for (my $row = 1; $row <= 9; $row++) {
		for (my $column = 1; $column <= 9; $column++) {
			$self->{$row}->{$column} = new Square();
		}
	}

	##
	# See if there's a file that's been passed in to the constructor. If so, load up the numbers
	##

	if (scalar(@_)) {
		my $file = shift;

		$self->loadFile($file);
	} 

	return $self;
}

sub loadFile {
	##
	# Parse the file into our Grid
	#
	# This does some very basic checking - it looks at the first 9 lines of the file (and complains if there aren't enough)
	# It looks at the first 9 characters of each line (and complains if there aren't enough)
	#
	# A digit from 1-9 will be set as the value for this square; any other character will be treated as a blank
	##

	my $self = shift;
	my $filename = shift;

	if (! -e $filename) {
		die "Unable to find file $filename";
	}

	if (! open (FILE, $filename)) {
		die "Unable to load file $filename";
	}

	my $lineCount = 1;

	while (my $line = <FILE>) {
		## Split each line into individual characters

		my @values = split(undef, $line);

		if (scalar(@values) < 9) {
			## There's not enough characters

			die ("Line $lineCount: only " . scalar(@values) . " entries");
		}

		for (my $i = 0; $i < 9; $i++) {
			## Take the first 9 characters and assign (non-0) digits to the squares. Ignore anything else

			if ($values[$i] >= 1 && $values[$i] <= 9) {
				$self->{$lineCount}->{$i + 1}->setValue($values[$i]);
				$self->addToCheckList($lineCount, $i + 1);
			}
		}

		$lineCount++;

		if ($lineCount > 9) {
			## Ignore extra lines in the file
			last;
		}
	}

	if ($lineCount < 9) {
		## The file is too short

		die "Not enough lines in the input file";
	}

	return $self;
}

sub printGrid {
	## Print the grid out prettily
	# Add lines so it's easier to read

	my $self = shift;

	print "+---+---+---+\n";

	for (my $row = 1; $row <= 9; $row++) {
		print "|";

		for (my $column = 1; $column <= 9; $column++) {
			## Check to see if this square is solved; if it is, print out the value of this square

			if (my $value = $self->{$row}->{$column}->isSolved()) {
				print $value;
			} else {
				print " ";
			}

			if ($column % 3 == 0) {
				print "|";
			}

		}

		print "\n";

		if ($row % 3 == 0) {
			print "+---+---+---+\n";
		}
	}
}

sub removeValue {
	## 
	# Pass in the details of one square, and a value; remove that value from the appropriate other squares - 
	# from squares in its row, column, and house. 
	##

	my ($self, $row, $column, $value) = @_;

	$self->removeValueFromRow ($row, $column, $value);
	$self->removeValueFromColumn ($row, $column, $value);
	$self->removeValueFromHouse ($row, $column, $value);
}

sub removeValueFromRow {
	##
	# Remove a value from all the other squares in a row where it's still a possibility
	# If any are removed, make sure that those squares are re-checked
	##

	my ($self, $rowToClear, $thisColumn, $value) = @_;

	for (my $column = 1; $column <=9; $column++) {
		if ($column == $thisColumn) {
			next;
		}

		if ($self->{$rowToClear}->{$column}->removeFromList($value)) {
			if (my $solution = $self->{$rowToClear}->{$column}->isSolved()) {
				$self->{"solved"}->{$rowToClear . "_" . $column} = 1;
			} else {
				$self->addToCheckList($rowToClear, $column);
			}
		}

	}
}

sub removeValueFromColumn {
	##
	# Remove a value from all the other squares in a column where it's still a possibility
	# If any are removed, make sure that those squares are re-checked
	##
	
	my ($self, $thisRow, $columnToClear, $value) = @_;

	for (my $row = 1; $row <= 9; $row++) {
		if ($row == $thisRow) {
			next;
		}

		if ($self->{$row}->{$columnToClear}->removeFromList($value)) {
			if (my $solution = $self->{$row}->{$columnToClear}->isSolved()) {
				$self->{"solved"}->{$row . "_" . $columnToClear} = 1;
			} else {
				$self->addToCheckList($row, $columnToClear);
			}
		}
	}
}

sub removeValueFromHouse {
	## 
	# Remove a value from all the other squares in a house where it's still a possibility
	# (A house is apparently the proper name for the 3x3 square that has all the numbers in it)
	# If any are removed, make sure those squares are re-checked
	##
	my ($self, $thisRow, $thisColumn, $value) = @_;

	## This gets the position of the house in the grid
	# It's a number from 0 to 2, and I multiply it by 3 and add 1 to get the starting number for squares in this house
	my @house = getHouseCoords($thisRow, $thisColumn);

	for (my $row = $house[0] * 3 + 1; $row <= $house[0] * 3 + 3; $row++) {
		for (my $column = $house[1] * 3 + 1; $column <= $house[1] * 3 + 3; $column++) {
			if ($row == $thisRow && $column == $thisColumn) {
				next;
			}

			if ($self->{$row}->{$column}->removeFromList($value)) {
				if (my $solution = $self->{$row}->{$column}->isSolved()) {
					$self->{"solved"}->{$row . "_" . $column} = 1;
				} else {
					$self->addToCheckList($row, $column);
				}
			}
		}
	}
}

sub getHouseCoords {
	##
	# Work out where this house sits in the grid.
	##
	my ($row, $column) = @_;

	return (int(($row - 1) / 3), int(($column - 1) / 3));
}

sub addToCheckList {
	##
	# See if this square is already in the list
	# If it's not, put it on the end to be re-checked
	##

	my ($self, $row, $column) = @_;

	if (! in_array ($self->{"coords"}, $row . "_" . $column)) {
		push (@{$self->{"coords"}}, $row . "_" . $column);
	}
}

sub in_array {
	## Pass in a reference to an array, and a search value
	# Returns whether the search value is in the array

	my ($array, $search) = @_;

	my %items = map {$_ => 1} @{$array};

	return (exists($items{$search}));
}

sub lookForSingletons {
	## 
	# We're looking for squares in a row, column, or house that are the only one in that set with that value
	# I've broken this down into two functions
	# This one steps through each possible set, and adds the coordinates of each square to an array; the second takes the 
	# array, and processes it - the latter doesn't need to know whether this is a row, column, or house
	#
	# I imagine I could generate all these in one single loop, but it would be somewhat messy; this is inefficient, but much 
	# easier to understand
	##

	my $self = shift;

	my $hits = 0;

	## Firstly, check the rows

	for (my $row = 1; $row <= 9; $row++) {
		my @squares = ();

		for (my $column = 1; $column <= 9; $column++) {
			if (! $self->{$row}->{$column}->isSolved()) {
				push (@squares, $row . "_" . $column);
			}
		}

		$hits += $self->do_lookForSingletons(@squares);
	}

	## Now, check the columns

	for (my $column = 1; $column <= 9; $column++) {
		my @squares = ();

		for (my $row = 1; $row <= 9; $row++) {
			if (! $self->{$row}->{$column}->isSolved()) {
				push (@squares, $row . "_" . $column);
			}
		}

		$hits += $self->do_lookForSingletons(@squares);
	}

	## And finally, the houses

	for (my $houseRow = 0; $houseRow <= 2; $houseRow++) {
		for (my $houseColumn = 0; $houseColumn <= 2; $houseColumn++) {
			my @squares = ();

			for (my $row = $houseRow * 3 + 1; $row <= $houseRow * 3 + 3; $row++) {
				for (my $column = $houseColumn * 3 + 1; $column <= $houseColumn * 3 + 3; $column++) {
					if (! $self->{$row}->{$column}->isSolved()) {
						push (@squares, $row . "_" . $column);
					}
				}
			}

			$hits += $self->do_lookForSingletons(@squares);
		}
	}

	## Return the number of solves we've made

	return $hits;
}

sub do_lookForSingletons {
	##
	# This code goes through an array of squares, and checks to see if there are any that are the only one with a given number
	# If so, solve that square
	##

	my $self = shift;
	my @coords = @_;

	my %required = ();

	## 
	# First of all, go through all the squares
	# Generate a hash as we go of all the numbers we need for this set of squares, and increment it as we add extra rows.
	##

	foreach my $square (@coords) {
		my ($row, $column) = split (/_/, $square);

		my @numbers = $self->{$row}->{$column}->getValues();

		foreach my $number (@numbers) {
			if (exists($required{$number})) {
				$required{$number}++;
			} else {
				$required{$number} = 1;
			}
		}
	}

	foreach my $number (keys(%required)) {
		if ($required{$number} == 1) {
			foreach my $square(@coords) {
				my ($row, $column) = split (/_/, $square);

				if ($self->{$row}->{$column}->isPossibleValue($number)) {
					$self->{$row}->{$column}->setValue($number);
					$self->removeValue($row, $column, $number);
					$self->{"solved"}->{$row . "_" . $column} = 1;
					last;
				}
			}
		}
	}
}

sub basicCheck {
	my $self = shift;

	while (my $square = shift (@{$self->{"coords"}})) {
		my ($row, $column) = split (/_/, $square);

		if ($row == 5 && $column == 1) {
			print "";
		}

		if (my $value = $self->{$row}->{$column}->isSolved()) {
			print ("$row, $column -> $value\n");
			$self->{"solved"}->{$row . "_" .$column} = 1;
			$self->removeValue ($row, $column, $value);
		}
	}
}

sub lookForGroups {
	my $self = shift;

	my $hits = 0;

	for (my $row = 1; $row <= 9; $row++) {
		my @squares = ();

		for (my $column = 1; $column <= 9; $column++) {
			if (! $self->{$row}->{$column}->isSolved()) {
				push (@squares, $row . "_" . $column);
			}
		}

		$hits += $self->do_lookForGroups(@squares);
	}

	for (my $column = 1; $column <= 9; $column++) {
		my @squares = ();

		for (my $row = 1; $row <= 9; $row++) {
			if (! $self->{$row}->{$column}->isSolved()) {
				push (@squares, $row . "_" . $column);
			}
		}

		$hits += $self->do_lookForGroups(@squares);
	}

	for (my $houseRow = 0; $houseRow <= 2; $houseRow++) {
		for (my $houseColumn = 0; $houseColumn <= 2; $houseColumn++) {
			my @squares = ();

			for (my $row = $houseRow * 3 + 1; $row <= $houseRow * 3 + 3; $row++) {
				for (my $column = $houseColumn * 3 + 1; $column <= $houseColumn * 3 + 3; $column++) {
					if (! $self->{$row}->{$column}->isSolved()) {
						push (@squares, $row . "_" . $column);
					}
				}
			}

			$hits += $self->do_lookForGroups(@squares);
		}
	}

	return $hits;
}

sub do_lookForGroups {
	my $self = shift;
	my @coords = @_;

	my $hits = 0;

	for (my $i = 0; $i < scalar(@coords); $i++) {
		my ($targetRow, $targetColumn) = split (/_/, $coords[$i]);

		my @targetKeys = $self->{$targetRow}->{$targetColumn}->getValues();

		my %required = map {$_ => 1} @targetKeys;

		my $success = 1;

		for (my $j = 0; $j < scalar(@coords); $j++) {
			if ($i == $j) {
				next;
			}

			my ($row, $column) = split(/_/, $coords[$j]);

			my @keys = $self->{$row}->{$column}->getValues();

			foreach my $key(@keys) {
				if (! exists($required{$key})) {
					$success = 0;
					last;
				} else {
					$required{$key}++;
				}
			}

			if ($success == 0) {
				last;
			}
		}

		if ($success) {
			## 
			# This means that we've got a square; and other squares in this set contain just a subset of this square's 
			# possible answers
			# Now we need to check - does %required have one key with a value of 1, and all the others equal?

			my $pass = 1;
			my $check = 0;

			my $keyCount = -1; 

			foreach my $key (keys(%required)) {
				if ($required{$key} == 1) {
					if ($check == 0) {
						$check = $key;
					} else {
						$pass = 0;
						last;
					}
				} else {
					if ($keyCount == -1) {
						$keyCount = $required{$key};
					} else {
						if ($keyCount != $required{$key}) {
							$pass = 0;
							last;
						}
					}
				}
			}

			if (($pass == 1) && ($check > 0)) {
				print "We have a group\n";

				print join ("\t", @coords) . "\n";
				print $check . "\n";
				exit;
			}
		}
	}

	return $hits;
}

sub solve {
	## Do the work of solving the puzzle

	my $self = shift;

	$self->basicCheck();

	while ((scalar(keys(%{$self->{"solved"}})) < 81) && 0) {
		my $lastSolved = scalar(keys(%{$self->{"solved"}}));

#		if ($self->lookForSingletons()) {
#			$self->basicCheck();
#		}

#		if ($self->lookForGroups()) {
#			$self->basicCheck();
#		}

		if ($lastSolved == scalar(keys(%{$self->{"solved"}}))) {
			print "Unsolvable\n";
			last;
		}
		$lastSolved = scalar(keys(%{$self->{"solved"}}));
	}
}

1;

##
# This isn't working properly. And is going to get a good re-write, I think.
#
# It's supposed to generate a list of squares that need checking - these are squares where we've removed at least one candidate number from 
# the list. But something isn't working right.
#
# What should happen is, we check each square. If it has just one possible value left, it's solved; so we can remove its value from all other 
# squares within its reach. All those squares go on the list of squares to be re-checked. When this list runs out, we're done with basic checking.
#
# This seems to work properly.
#
# The issue is with the code looking for singletons. 
#
# It's supposed to generate a set of squares from one column, row or house. It pulls just ones that have yet to be solved. Then it parses that set, 
# looking for candidates that exist in just one square. What seems to have happened, though, is that an earlier solved square isn't going through
# the removal process. So the solved square isn't showing up in the set, but its number is, and is appearing in one of the set of squares, which is
# then kicking off the removal process and taking it out of the solved square.
##
