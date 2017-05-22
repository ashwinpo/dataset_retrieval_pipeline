#!/usr/bin/perl
use warnings;
use strict;

my %all_docs;
my %combined_score;

foreach my $file (@ARGV)
{
    open(DATA,"$file") or die "can't open $file!\n";
    while(<DATA>)
    {
	chomp;    
	next if length($_) == 0;
	my @vals = split(/\ /);
	${$all_docs{$vals[0]}}{$vals[2]} = 1;
       	
	push @{${$combined_score{$vals[0]}}{$vals[2]}}, 1/($vals[3]); # (1/rank) as score
    }
    close(DATA);
}

## Prepare


## sort
foreach my $query_id (keys(%all_docs))
{

    my @docs = keys(%{$all_docs{$query_id}});
    my %scores;
    
    foreach my $doc_id (@docs)
    {
	$scores{$doc_id} = mean(\@{${$combined_score{$query_id}}{$doc_id}});
    }
    
    @docs = sort {$scores{$b} <=> $scores{$a}} @docs;
    
    ## print out
    my $i = 1;
    foreach my $doc_id (@docs)
    {
	print join("\t",($query_id,0,$doc_id,$i,$scores{$doc_id},"auto-run")),"\n";
	$i++;
    }
}


sub mean
{
    my ($ref) = @_;
    
    my $s = 0;
    for(@{$ref})
    {
	$s += $_;
    }
    return($s/@{$ref})
}
