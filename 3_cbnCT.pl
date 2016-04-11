#!/usr/bin/perl

# -----------------------------------------
# Updated Date: 2014/03/24
# Input: The control and the treatment files generated by getLargeData.pl.
# Output: The combined file contains one transcript with its read counts of control and its read counts of treatment.
# Environemt: Linux or Windows
# Description: The pre-processing step is before the gene level analysis and the transcript level analysis.
#              Combine each item on transcript level with its read counts of control and treatment level.
# -----------------------------------------

use strict;

if(scalar(@ARGV) < 3) {
	die("Usage: perl ./cbnCT.pl <control.txt> <testing.txt> <output.txt>\n");
}

# global variables
my %control = ();
my %testing = ();
my @temp = ();

for(my $times = 0 ; $times < 2 ; $times++) {
	open(fin,$ARGV[$times]) or die("Error: Make sure that $ARGV[$times] exists.\n");
	foreach my $line (<fin>) {
		chomp($line);
		@temp = split("\t",$line);
		if($times == 0) {
			$control{$temp[0]} = $temp[1];
		}
		else {
			$testing{$temp[0]} = $temp[1];
		}
	}
}

close(fin);

open(fout,">$ARGV[2]") or die("Error: Output file $ARGV[2] went wrong.\n");
print fout "transcript\tcontrol\ttreatment\n";
foreach my $key (keys(%control)) {
	print fout "$key\t$control{$key}\t";
	if(exists($testing{$key})) {
		print fout "$testing{$key}\n";
	}
	else {
		print fout "0\n";
	}
}
foreach my $key (keys(%testing)) {
	if(exists($control{$key})) {
		next;
	}
	else {
		print fout "$key\t0\t$testing{$key}\n";
	}
}
close(fout);


