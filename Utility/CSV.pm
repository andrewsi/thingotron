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
		'_errorLevel'	=>	0, 
		'_separator'	=> 	',', 
		'_quote'	=>	'"', 
		'_newline'	=>	"\n", 
		'_escape'	=>	"\\", 
		'_eof'		=>	chr(4), 
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

sub error {
	my $self = shift;

	return $self->{'_errorMessage'};
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
		$self->{'_errorLevel'} = 1;
		return 0;
	}

	my $fh;

	if (! open ($fh, $self->{'_filename'})) {
		$self->{'_errorMessage'} = "Unable to open " . $self->{'_filename'};
		$self->{'_errorLevel'} = 1;
		return 0;
	}

	##
	# We can be in one of the following states:
	# 	- inside a quoted field; an unescaped quote will finish this field, and anything else will be catted 
	# 		(if it's escaped, lose the escape character)
	# 	- inside a non-quoted field
	# 		- newline will finish this field (and this line)
	# 		- a quote will return invalid data
	# 		- a separator will finish this field
	# 		- an escape character is treated as a literal
	# 	- waiting for data
	# 		- if this is the start of a line, the next character needs to be a quote, or regular data
	# 		- otherwise, the next character needs to be a separator or a newline
	##

	my $state = 0;			# 	0 - waiting to start a new field
					#	1 - reading a regular field
					#	2 - reading a quoted field
	
	my $data = ();
	my $line = ();
	my $string = "";
	my $inEscape = 0;

	my $done = 0;
	my $error = 0;

	while ((! ($done + $error)) && ((my $i = read $fh, my $character, 1) != 0)) {
		if ($state == 0) {
			if ($character eq $self->{'_quote'}) {
				$state = 2;
				$string = "";
				$inEscape = 0;
			} elsif ($character eq $self->{'_separator'}) {
				push (@$line, $string);
				$string = '';
			} elsif (($character eq $self->{'_eof'}) || ($character eq $self->{'_newline'})) {
				push (@$line, $string);
				$string = '';
				push (@$data, $line);
				$line = ();
			} else {
				$state = 1;
				$string .= $character;
			}
		} elsif ($state == 1) {
			if ($character eq $self->{'_separator'}) {
				$state = 0;
				push (@$line, $string);
				$string = '';
			} elsif (($character eq $self->{'_newline'}) || ($character eq $self->{'_eof'})) {
				push (@$line, $string);
				$string = '';
				push (@$data, $line);
				$line = ();
				$state = 0;
			} elsif ($character eq $self->{'_quote'}) {
				$error = 1;
				$self->{'_errorMessage'} = "Illegal quote";
				$self->{'_errorLevel'} = 2;
			} else {
				$string .= $character;
			}
		} elsif ($state == 2) {
			if ($character eq $self->{'_eof'}) {
				$self->{'_errorMessage'} = "Unexpected end of file";
				$self->{'_errorLevel'} = 4;
			} elsif ($inEscape) {
				$inEscape = 0;
				if ($character eq $self->{'_quote'}) {
					$string .= $character;
				} else {
					$string .= $self->{'_escape'} . $character;
				}
			} else {
				if ($character eq $self->{'_escape'}) {
					$inEscape = 1;
				} elsif ($character eq $self->{'_quote'}) {
					$state = 3;
					push (@$line, $string);
					$string = '';
				} else {
					$string .= $character;
				}
			}
		} elsif ($state == 3) {
			if ($character eq $self->{'_separator'}) {
				push (@$line, '');
				$state = 0;
			} elsif ($character eq $self->{'_newline'}) {
				push (@$data, $line);
				$line = ();
				$state = 0;
			} else {
				$error = 1;
				$self->{'_errorMessage'} = "Illegal character";
				$self->{'_errorLevel'} = 2;
			}
		} 
	}

	if (defined($line)) {
		push (@$data, $line);
	}

	return $data;
}

sub writefile {
	my $self = shift;
	my $rows = shift;

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
