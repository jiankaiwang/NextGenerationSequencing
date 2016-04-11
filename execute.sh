/home/JKW/programs/bowtie2-2.1.0/bowtie2-align -x ../../GENCODE/gencode.v19.pc_transcripts/hsa_transcripts -1 ../sequence/C_S1_L001_R1_001.fastq -2 ../sequence/C_S1_L001_R2_001.fastq -S ./control.sam
/home/JKW/programs/bowtie2-2.1.0/bowtie2-align -x ../../GENCODE/gencode.v19.pc_transcripts/hsa_transcripts -1 ../sequence/T_S2_L001_R1_001.fastq -2 ../sequence/T_S2_L001_R2_001.fastq -S ./treatment.sam
python ./0_preprocess.py control.sam treatment.sam 4 4
