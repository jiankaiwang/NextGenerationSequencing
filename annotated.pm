#!/usr/bin/perl

# -----------------------------------------
# Updated Date: 2014/03/24
# Input: The annotated database was treated as inputs.
# Output: The small database whose entries could be referred to getTranscript.r.
# Environemt: Linux or Windows
# Description: The code is implemented by pointer and was executed by class (new). Try to extract the same gen name, 
#              but different transcript label.
# -----------------------------------------

package annotated;

sub new {
	my $class = shift;
	my $self = {
			_chr => shift,
			_source => shift,
			_type => shift,
			_strand => shift,
			_geneID => shift,
			_transcriptID => shift,
			_geneType => shift,
			_geneName => shift,
			_transcriptName => shift,
	};
	bless($self,$class);
	return $self;
}

sub getContent {
	my ($self, $getOption) = @_;
	# Perl does not support switch
	if($getOption == 0) { return $self->{_chr}; }
	elsif($getOption == 1) { return $self->{_source}; }
	elsif($getOption == 2) { return $self->{_type}; }
	elsif($getOption == 3) { return $self->{_strand}; }
	elsif($getOption == 4) { return $self->{_geneID}; }
	elsif($getOption == 5) { return $self->{_transcriptID}; }
	elsif($getOption == 6) { return $self->{_geneType}; }
	elsif($getOption == 7) { return $self->{_geneName}; }
	elsif($getOption == 8) { return $self->{_transcriptName}; }
	else { }
}
1;


