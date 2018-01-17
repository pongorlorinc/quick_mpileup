# quick_mpileup

Calculate mpileup of BED positions, without going through entire BAM file (as forced by samtools mpileup). Uses the samtools mpileup -r \<region\> for each entry, which is able to utilize the index of BAM files.

## Requirements
To run the programs, Biopython is needed.

      a) Either install globally on machine: 
       pip install Biopython

      b) or create a virtualenv:
       virtualenv venv
       source venv/bin/activate
       pip install Biopython
     
## Usage:

      perl fast_mpileup.pl -bam <input BAM> -o <output mpileup> -b <input bed> -f <input genome fasta>
      
       Parameters:
        -bam  input BAM file (indexed)
        -o    output mpileup file
        -f    genome fasta file
        -b    bed coordinated to perform mpileup
        
        Additional parameters:
         -e   +/- bases to extend bed coordinates (default: 0)
        
## Mini comparison of performance

Processing BAM file (size ~2.5Gb)
Number of entries: ~16,000

quick_mpileup: 6min 5sec
samtools mpileup (no reference): 1min
samtools mpileup (with ref): 
