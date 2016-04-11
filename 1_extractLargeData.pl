#!/usr/bin/perl

# -----------------------------------------
# Updated Date: 2014/03/24
# Input: Each sub files generated by preprocess.py
# Output: The paired reads fit the policy described at progress report (3/18,3/25).
# Environemt: Linux or Windows
# Description: Try to extract paired reads which fit the policy that only two unmapped pairs are abandoned.
# -----------------------------------------

use strict;

if(scalar(@ARGV) < 2) {
	die("Usage: perl ./extractMap.pl <input.sam> <output.sam>");
}

open(fin, "$ARGV[0]") or die("Error: Make sure that input file exists.\n");
if(! open(fout, ">$ARGV[1]")) {
	close(fin);
	die("Error: The output file went wrong.\n");
}

# global variables
my @temp = ();
my $checkSelfMap = 0;
my $checkPairMap = 0;
my $selfMap = 5; # FLAG 101
my $pairMap = 9; # FLAG 1001

foreach my $line(<fin>) {
	chomp($line);
	@temp = split("\t",$line);

	# comment
	if($temp[0] =~ m/^@/) {
		next;
	}

	$checkSelfMap = $temp[1] & $selfMap;
	$checkPairMap = $temp[1] & $pairMap;

	# and: both pair are unmapped
	if($checkSelfMap == $selfMap and $checkPairMap == $pairMap) {
		next;
	}
	print fout "$line\n";
}

close(fin);
close(fout);