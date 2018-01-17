use strict; use warnings;
use Cwd;
my $dir = getcwd;
use Cwd 'abs_path';

my $mpiler = "$dir/bin/generate_mpileup_fast.pl";
my $ref_formatter = "$dir/bin/subNmpileup.py";

my $genome;
my $bam;
my $mpileup_out;
my $bed;
my $pm_bed = 0;

my $return_value;

parse_commands();

print "Path: $dir\n";
print "BAM file: $bam\n";
print "BED file: $bed\n";
print "Genome: $genome\n";
print "Output: $mpileup_out\n";
print "BED coordinate extended by: $pm_bed\n";

print "\nCreating temporary mpileup (without reference)\n";
$return_value = system("perl $mpiler $bed $bam $mpileup_out.tmp $pm_bed");

if(-e "$mpileup_out.tmp") {
	print "Annotating mpileup with ref bases, and finalyzing results\n";
	print "\tloading genome might take some time and RAM, approximately as size of file\n";
	system("python $ref_formatter $mpileup_out.tmp $genome > $mpileup_out");
}

unlink("$mpileup_out.tmp");
print "Done\n"; 

sub parse_commands {
	for(my $i = 0; $i <= $#ARGV; $i++) {
		if($ARGV[$i] eq "-bam") {
			$bam = $ARGV[$i+1];
		}

		if($ARGV[$i] eq "-o") {
			$mpileup_out = $ARGV[$i+1];
		}

		if($ARGV[$i] eq "-bed" || $ARGV[$i] eq "-b") {
			$bed = $ARGV[$i+1];
		}

		if($ARGV[$i] eq "-f" || $ARGV[$i] eq "--fasta") {
			$genome = $ARGV[$i+1];
		}

		if($ARGV[$i] eq "-e") {
			$pm_bed = $ARGV[$i+1];
		}
	}

	if(!defined $bam) {
		print "[ ERROR ] no BAM specified\n";
		print_usage();
	}

	if(!defined $genome) {
		print "[ ERROR ] no genome file specified\n";
		print_usage();
	}

	if(!defined $bed) {
		print "[ ERROR ] no BED file specified\n";
		print_usage();
	}

	if(!defined $mpileup_out) {
		print "[ ERROR ] no output file name specified\n";
		print_usage();
	}

	if($bam !~ m/(.+)(\.bam$)/) {
		print "[ ERROR ] \"$bam\" does not end with BAM, is it a BAM file?\n";
		print_usage();
	}

	unless(-e $bam) {
		print "[ ERROR ] genome file \"$bam\" not found\n";
		print_usage();
	}

	unless(-e $genome) {
		print "[ ERROR ] genome file \"$genome\" not found\n";
		print_usage();
	}

	unless(-e $bed) {
		print "[ ERROR ] BED file \"$bed\" not found\n";
		print_usage();
	}

	unless(-e "$bam.bai") {
		print "[ ERROR ] \"$bam\" is missing index file, trying: samtools index $bam\n";
		system("samtools index $bam");

		unless(-e "$bam.bai") {
			print "[ ERROR ] could not create index for \"$bam\"\n";
			print_usage();
		}		
	}

	unless($genome =~ m/(.+)(\.fa$)/ || $genome =~ m/(.+)(\.fasta$)/) {
		print "[ ERROR ] suffix of \"$genome\" doesn't match \".fa\" or \".fasta\", is it a fasta file?\n";
		print_usage();
	}

	unless($bed =~ m/(.+)(\.bed)/) {
		print "[ ERROR ] suffix of \"$bed\" doesn't match \".bed\", is it a BED file?\n";
		print_usage();
	}

	if(-e $mpileup_out) {
		print "[ ERROR ] file \"$mpileup_out\" already exists, please change name to run analysis\n";
		print_usage();
	}

	if($pm_bed !~ m/(^\d+|\d$)/) {
		print "[ ERROR ] variable \"$pm_bed\" does not seem numeric\n";
		print_usage();
	}
}

sub print_usage {
	print "\nUsage: perl fast_mpileup -bam <input_BAM> -o <output_mpileup> -f <genome_fasta> -b <BED_file>\n\n";
	print "\tParameters:\n";
	print "\t-bam\tinput BAM file (indexed)\n";
	print "\t-o\toutput mpileup file\n";
	print "\t-f\tgenome fasta file\n";
	print "\t-b\tbed coordinated to perform mpileup\n\n";
	print "\tAdditional parameters:\n";
	print "\t-e\t+/- bases to extend bed coordinates (default: 0)\n\n";
	exit;
}
