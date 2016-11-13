use strict;
use warnings;

my $a = 0;
my $i = 0;
while(<>){
	if(m/^packages/){
		$a = 1;
		next;
	}
	next unless $a;
	if(m/^  ([^\s]+):\s*$/){
		print "$1 ";
		next
	}
	$a = 0 unless m/^ /
}
