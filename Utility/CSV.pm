package CSV;

##
# Package to handle reading and writing to CSV files
# (Though it will also let you use a different separator, so it's not technically just a CSV)
# Methods will let you read a file, either in its entirety or line by line, and write them
#
# The formatting of a CSV is: one or more lines; each containing one or more fields
# Fields are separated by a specific character. They can always be wrapped with quotes; if they contain 
# 	a special character (the separator; a line break; a quote) then they must be wrapped with quotes.
# If this character is a quote, we can carry on reading until we get to an unescaped quote.
# If this character is a newline, this line is finished.
# If this character is a separator, start a new field
# Otherwise, add this character to the existing field
#
#
# (No idea yet how I'm going to be passing data around here - using the LinkedList class with a set of 
# anonymous  objects stored within?)
##

use strict;

sub new {
	## 
	# Create a new CSV object
	# This will take one parameter, which is the filename to use for this CSV file
	# Reading and writing it will be dealt with seperately
	##
	
	my $class = shift;

	my $self = {
		'_filename'	=>	'',
		'_errorMessage'	=>	'', 
		'_separator'	=> 	',', 
		'_quote'	=>	'"', 
		'_newline'	=>	"\n", 
		'_escape'	=>	"\\", 
	};

	if (scalar(@_)) {
		$self->{'_filename'} = shift;

		if (scalar(@_)) {
			$self->{'_separator'}	= shift;
		}
	}

	bless $self, $class;

	return $self;
}

sub filename {
	my $self = shift;

	if (scalar(@_)) {
		$self->{'_filename'} = shift;
	} 

	return $self->{'_filename'};
}

sub loadfile {
	my $self = shift;

	if (! -e $self->{'_filename'}) {
		$self->{'_errorMessage'} = "Unable to find " . $self->{'_filename'};
		return 0;
	}

	my $fh;

	if (! open ($fh, $self->{'_filename'})) {
		$self->{'_errorMessage'} = "Unable to open " . $self->{'_filename'};
		return 0;
	}

	my $data = ();

	while (! eof($fh)) {
		if (! (my $thisLine = $self->loadline($fh))) {
			$self->{'_errorMessage'} = "Badly formed file";
			return 0;
		} else {
			push (@$data, $thisLine);
		}
	}

	return $data;
}

sub loadline {
	my $self = shift;
	my $filehandle = shift;

	my $inVariable = 0;		## This tracks whether we're currently inside a quoted field
	my $isEscape = 0;

	my $data = [];
	my $fieldCount = 0;
	my $string = '';

	my $done = 0;
	my $haveData = 0;

	while ((! $done) && ((my $i = read $filehandle, my $character, 1) != 0)) {
		if ($inVariable) {
			if ($isEscape) {
				if ($character eq $self->{'_escape'}) {
					$string .= $character;
				} elsif ($character eq $self->{'_quote'}) {
					$string .= $character;
				} elsif ($character eq $self->{'_newline'}) {
					$string .= $character;
				} elsif ($character eq $self->{'_seperator'}) {
					$string .= $character;
				} else {
					$string .= $self->{'_escape'} . $character;
				}
			} elsif ($character eq $self->{'_quote'}) {
				push (@$data, $string);
				$string = '';
				$inVariable = 0;
				$haveData = 0;
			} else {
				if ($character eq $self->{'_escape'}) {
					$isEscape = 1;
				} else {
					$string .= $character;
				}
				$haveData = 1;
			}
		} else {
			if ($character eq $self->{'_quote'}) {
				$inVariable = 1;
			} elsif ($character eq $self->{'_newline'}) {
				if ($haveData) {
					push (@$data, $string);
				}
				$done = 1;
			} elsif ($character eq $self->{'_separator'}) {
				push (@$data, $string);
				$string = '';
				$haveData = 0;
			} else {
				$string .= $character;
				$haveData = 1;
			}
		}
	}

	if ((! $done) || ($inVariable)) {
		if (! eof($filehandle)) {
			$self->{'_errorMessage'} = "Input file in invalid format";
			return 0;
		}
	}

	return $data;
}

sub writefile {
	my $self = shift;
	my $rows = shift;

	#if (! open (FILE, "r", $self->{'_filename'})) {
	#$self->{'_errorMessage'} = "Unable to open " . $self->{'_filename'} . " for writing";
	#return 0;
	#}

	foreach my $thisRow (@$rows) {
		for (my $i = 0; $i < scalar(@$thisRow); $i++) {
			my $match = $self->{'_escape'} . $self->{'_quote'};

			$$thisRow[$i] =~ s/([$match])/$self->{'_escape'}$1/g;

			my $lookup = $match . $self->{'_seperator'} . $self->{'_newline'};

			if ($$thisRow[$i] =~ /[$lookup]/) {
				$$thisRow[$i] = $self->{'_quote'} . $$thisRow[$i] .  $self->{'_quote'};
			}
		}

		print join($self->{'_separator'}, @$thisRow) . "\n";
	}
}

1;
