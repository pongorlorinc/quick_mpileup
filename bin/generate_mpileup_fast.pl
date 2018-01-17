use strict; use warnings;

open FH, $ARGV[0] or die;
my @bed = <FH>;
close(FH);
chomp(@bed);

my $count = 0;

my $in = $ARGV[1];
my $out = $ARGV[2];

my $plus_minus = 0;

if(defined $ARGV[3]) {
	$plus_minus = $ARGV[3];
}

if(!defined $out) {
	print "[ ERROR ] Missing arguments\n";
	print_usage();
}

unless(-e "$in.bai") {
	print "[ ERROR ] Missing BAM index file\n";
	print_usage();
}

if(-e $out) {
	print "[ ERROR ] Output \"$out\" already exists\n";
	print_usage();
}

system("touch $out");

unless(-e $out) {
	print "[ ERROR ] could not create output\n";
	print_usage();
}

if($plus_minus !~ m/(^\d+|\d$)/) {
	print "[ ERROR ] distance set is not integer: $plus_minus\n";
	print_usage();
}

#print "\n## pileup PARAMETERS ##
#Input BED: $ARGV[0]
#Input BAM: $in
#output mpileup: $out
#+/- distance (bp) from coordinates: $plus_minus
######################\n\n"; 
my $perc = 0;

for(my $i = 0; $i <= $#bed; $i++) {
	if($i%(int($#bed/10)) == 0) {
		print "completed: $perc%\n";
		$perc += 10;
	}

	if($bed[$i] !~ m/(\#)(.+)/) {
		my @line = split "\t", $bed[$i];
		my $start = $line[1] - $plus_minus;
		my $end = $line[2] + $plus_minus;

		my $return = system("samtools mpileup -B -r $line[0]:$start-$end $in >> $out 2> /dev/null");

		if($return == 2) {
			print "[ STOP ] got signal $return\n";
			if(-e $out) {
				unlink($out);
			}

			exit 2;
		}
	}
}

sub print_usage {
	print "\tUsage: perl generate_mpileup_fast.pl <bed> <in.bam> <out.mpileup> <optional: +/- bp from bed>\n";
	print "\n\t\tTo stop script, use cntrl+c or create file named \"stop\" (command example: \"touch stop\")\n";
	exit;
}

