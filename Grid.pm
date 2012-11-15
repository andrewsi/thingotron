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
## 

use strict;
use Square;

sub new {
	my $class = shift;

	## 
	# We're going to store a set of Square classes in a 9x9 array, stores as:
	# $self->{row}->{col}
	# We'll also store:
	# coords - a list of squares that we need to check
	# solved - the number of squares that we've solved already
	##

	my $self = {};

	bless $self, $class;

	$self->{"coords"} = [];
	$self->{"solved"} = 0;

	##
	# Start out by creating an empty grid, with no numbers set
	# Also add each square to the 'to be checked' list
	##

	for (my $row = 1; $row <= 9; $row++) {
		for (my $col = 1; $col <= 9; $col++) {
			$self->{$row}->{$col} = new Square();
			$self->addToCheckList($row, $col);
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
				$self->removeValue ($lineCount, $i + 1, $values[$i]);
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

	for (my $rows = 1; $rows <= 9; $rows++) {
		print "|";

		for (my $cols = 1; $cols <= 9; $cols++) {
			## Check to see if this square is solved; if it is, print out the value of this square

			if (my $value = $self->{$rows}->{$cols}->isSolved()) {
				print $value;
			} else {
				print " ";
			}

			if ($cols % 3 == 0) {
				print "|";
			}

		}

		print "\n";

		if ($rows % 3 == 0) {
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

	for (my $col = 1; $col <=9; $col++) {
		if ($col == $thisColumn) {
			next;
		}

		if ($self->{$rowToClear}->{$col}->removeFromList($value)) {
			$self->addToCheckList($rowToClear, $col);
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
			$self->addToCheckList($row, $columnToClear);
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
		for (my $col = $house[1] * 3 + 1; $col <= $house[1] * 3 + 3; $col++) {
			if ($row == $thisRow && $col == $thisColumn) {
				next;
			}

			if ($self->{$row}->{$col}->removeFromList($value)) {
				$self->addToCheckList($row, $col);
			}
		}
	}
}

sub getHouseCoords {
	##
	# Work out where this house sits in the grid.
	##
	my ($row, $col) = @_;

	return (int(($row - 1) / 3), int(($col - 1) / 3));
}

sub addToCheckList {
	##
	# See if this square is already in the list
	# If it's not, put it on the end to be re-checked
	##

	my ($self, $row, $col) = @_;

	if (! in_array ($self->{"coords"}, $row . "_" . $col)) {
		push (@{$self->{"coords"}}, $row . "_" . $col);
	}
}

sub in_array {
	## Pass in a reference to an array, and a search value
	# Returns whether the search value is in the array

	my ($array, $search) = @_;

	my %items = map {$_ => 1} @{$array};

	return (exists($items{$search}));
}

sub solve {
	## Do the work of solving the puzzle

	my $self = shift;

	while (my $square = shift (@{$self->{"coords"}})) {
		my ($row, $col) = split (/_/, $square);

		if (my $value = $self->{$row}->{$col}->isSolved()) {
			$self->{"solved"}++;
			$self->removeValue ($row, $col, $value);
		}
	}

	print $self->{"solved"} . "\n";

	## There are extra checks that I can add here:
	# - look for singletons
	# 	if there is only one place where a given number can fit, we can solve it.
	#
	# - look for groups
	# 	if there are three squares, and their possible values are (1,2), (1,2) and (1,2,3) then the third square 
	# 	has to be 3
	##
}

1;
