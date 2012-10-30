package LoadConfig;

##
# Load a generic config file
#
# The format required is:
#
# fieldname1 = value
# fieldname2 = value
#
# [section1]
#
# fieldname1 = value
#
# [section2]
#
# fieldname1 = value
# fieldname2 = value
#
# It will return a hash of the values in the file; global settings come before the first [section] tag, and are directly 
# accessible; each section becomes a reference to a hash with all its options in there.
#
# Comments can be added to a config file with a hash. All settings after a [section] tag will go into that section's has, 
# until either the end of the file, or a new [section] tag.
#
# Returns a hash with error information if something went wrong (mainly that the file was poorly formatted - in which case, 
# it'll tell you which line had the problem).
#
##

use strict;

sub new {
	my $class = shift;

	my $configFile = shift;

	my $self = {};

	bless $self, $class;

	if (! -e $configFile) {
		$self->{"error"} = 1;
		$self->{"errorMessage"} = "${configFile} does not exist";
	} 

	if (! open (FILE, $configFile)) {
		$self->{"error"} = 1;
		$self->{"errorMessage"} = "Unable to open ${configFile}";
	}

	if (defined($self->{"error"})) {
		return $self;
	}

	my $lineCount = 0;

	my $errorMessage = "";
	my $section = "";

	while (my $line = <FILE>) {
		chop $line;

		$lineCount++;

		$line =~ s/#.*//;
		$line =~ s/\s+$//;

		if ($line eq "") {
			next;
		} 

		if (my ($key, $value) = $line =~ /^\s*(.+?)\s*=\s*(.*)\s*$/) {
			if ($section eq "") {
				if (defined($self->{$key})) {
					$errorMessage = "Field ${key} redefined on line ${lineCount}";
					last;
				} else {
					$self->{$key} = $value;
				}
			} else {
				if (defined($self->{$section}->{$key})) {
					$errorMessage = "Field ${section}->${key} redefined on line ${lineCount}";
					last;
				} else {
					$self->{$section}->{$key} = $value;
				}
			}
		} elsif ($line =~ /^\s*\[(.*)\]\s*$/) {
			$section = $1;
			if (defined ($self->{$section})) {
				$errorMessage = "Section ${section} redefined on line ${lineCount}";
				last;
			} else {
				$self->{$section} = {};
			}
		} else {
			$errorMessage = "Unable to parse ${configFile} - parse error on line ${lineCount}";
			last;
		}
	}

	if ($errorMessage ne "") {
		$self->{"error"} = 1;
		$self->{"errorMessage"} = $errorMessage;
	}

	return $self; 
}

sub hasError {
	my $self = shift;

	if (defined $self->{"error"}) {
		return $self->{"errorMessage"};
	}

	return 0;
}


1;
