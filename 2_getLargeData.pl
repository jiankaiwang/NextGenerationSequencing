#!/usr/bin/perl

# -----------------------------------------
# Updated Date: 2014/03/24
# Input: several sub-files generated by extractLargeData.pl
# Output: the control or the treatment collected data that count each item (transcript)
# Environemt: Linux or Windows
# Description: Generate the control or the treatment collected file showing each transcript with its counting.
# -----------------------------------------

use strict;

if(scalar(@ARGV) < 3) {
	# die("Usage: perl ./getTranscript.pl <check1.sam> <check2.sam> <check3.sam> <check4.sam> <output.sam>\n");
	# total passed files = output + all check1.sam, not containing passed value
	die("Usage: perl ./getTranscript.pl <total passed files> <output.sam> <check1.sam> [<check2.sam>, [<check3.sam>]]\n");
}

# global variables
my %transcript = ();
my @temp = ();
my $fstRef = 0;
my $getTrans = "";

# -1 in scalar(@ARGV): output file
for (my $times = 2; $times < scalar(@ARGV); $times++) {
	if(! open(fin,"$ARGV[$times]")) {
		die("Error: Make sure that $ARGV[$times] exists.\n");
	}
	print "$ARGV[$times]\n";
	foreach my $line (<fin>) {
		chomp($line);
		@temp = split("\t",$line);
		# notice: fstRef was not needed to initate to 0 due to the dividing the origin sam file
		if($fstRef == 0) {
			$fstRef = 1;
			$getTrans = $temp[2];
			if(exists($transcript{$getTrans})) {
				$transcript{$getTrans} += 1;
			}
			else {
				$transcript{$getTrans} = 1;
			}
		}
		else {
			$fstRef = 0;
			next;
		}
	}
}

#print scalar(keys(%transcript));
#print "\n";

if(! open(fout,">$ARGV[1]")){
	close(fin);
	die("Error: Output file went wrong.\n");
}

foreach my $key (keys(%transcript)) {
	print fout "$key\t$transcript{$key}\n";
}

close(fin);
close(fout);