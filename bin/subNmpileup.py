import os
import sys

from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord

genome_file = sys.argv[2]
records = SeqIO.to_dict(SeqIO.parse(open(genome_file), 'fasta'))

mpileup_file = sys.argv[1]

mpileup = open(mpileup_file, "r")

for line in mpileup:
	line = line.rstrip().split('\t')
	position = int(line[1]) - 1

	if line[0] in records:
		line[2] = records[line[0]].seq[int(line[1])-1].upper()

	print ("%s" % ('\t'.join(str("%s" % i) for i in line)))
