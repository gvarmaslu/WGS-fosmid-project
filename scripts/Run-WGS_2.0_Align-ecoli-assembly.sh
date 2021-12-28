#!/bin/bash -l

echo "Align with Ecoli and assembly"

#./Run-WGS_2.0_Align-ecoli-assembly.sh > Run-WGS_2.0_Align-ecoli-assembly.sh.log 2>&1

##########################################################

Ref_EC="/home/REF/Escherichia-coli_K-12/"
work_dir=/home/
mkdir -p ${work_dir}Align-ecoli/
out_dir1=${work_dir}Align-ecoli/
cd ${work_dir}

###2 Genome generate (index)
<'
bowtie2-build GCF_000005845.2_ASM584v2_genomic.fna Ecoli
bowtie2-build pcc1fos.fa pcc1fos
'
#########
##########################################################
#### Mapped reads to the Ecoli

find /home/RAWDATA/ -name "*_1.fq.gz" |sort|while read READ_FW;
do

FILEBASE=$(basename $READ_FW | cut -d_ -f1 );
DIRNM=$(dirname $READ_FW );
SN=${out_dir1}${FILEBASE}
echo $READ_FW $FILEBASE $DIRNM


###3 Align to genome Ecoli
nice -n 5 bowtie2 -x ${Ref_EC}Ecoli -1 ${DIRNM}"/"${FILEBASE}"_1.fq.gz" -2 ${DIRNM}"/"${FILEBASE}"_2.fq.gz" -S ${SN}".sam" -p 70;

###4 Comvert SAM to BAM and sort
nice -n 5 samtools view -bS ${SN}".sam" -@ 70 | samtools sort - -o ${SN}".bam" -@ 70; 

###5 index bam file
nice -n 5 samtools index ${SN}.bam
	
rm ${SN}".sam";

echo "script all done....step1"

##########################################################
#### extract unmapped reads from Ecoli map

#nice -n 5 samtools view -h -b -f 4 -@ 70 10F.bam | samtools sort - -o 10F_unmap-fo.bam -@ 70
nice -n 5 samtools view -h -b -f 4 -@ 70 ${SN}.bam | samtools sort - -o ${SN}"_unmap-ec.bam" -@ 70

#### index bam file
nice -n 5 samtools index ${SN}"_unmap-ec.bam"

# convert BAM to FASTQ
#bamToFastq -i 10F_unmap-fo.bam -fq 10F_unmap-fo_1.fq -fq2 10F_unmap-fo_2.fq
#bamToFastq -i ${SN}"_unmap-fo.bam" -fq ${SN}"_unmap-fo_1.fq" -fq2 ${SN}"_unmap-fo_2.fq"

nice -n 5 samtools fastq -@ 70 ${SN}"_unmap-ec.bam" \
-1 ${SN}"_unmap-ec_1.fq.gz" \
-2 ${SN}"_unmap-ec_2.fq.gz" \
-0 /dev/null -s /dev/null -n

# remove bam file 
rm ${SN}"_unmap-ec.bam";
rm ${SN}"_unmap-ec.bam.bai";

###############################################################
#  Assembly with SPAdes
################
#https://github.com/ablab/spades#bgc

SPAdes=/bioinfo/SPAdes/SPAdes-3.15.3-Linux/bin/spades.py
MPS=/bioinfo/SPAdes/SPAdes-3.15.3-Linux/bin/metaplasmidspades.py

#nice -n 5 ${SPAdes} --pe1-1 10F_cdhit_R1.fq --pe1-2 10F_cdhit_R2.fq -o 10F_spades_out_k127 -t 70 -k 127

nice -n 5 ${SPAdes} --pe1-1 ${SN}"_unmap-ec_1.fq.gz" --pe1-2 ${SN}"_unmap-ec_2.fq.gz" --metaplasmid -o ${SN}_unmap-ec_metaplasmid -t 70


###############################################################
#  Align reads back to the SPAdes assembly for quality assessment 
################
###2 create index for ref
bowtie2-build ${SN}_unmap-ec_metaplasmid/scaffolds.fasta ${SN}_unmap-ec_metaplasmid/scaffolds

###3 Align to genome assembly
nice -n 5 bowtie2 -x ${SN}_unmap-ec_metaplasmid/scaffolds -1 ${SN}"_unmap-ec_1.fq.gz" -2 ${SN}"_unmap-ec_2.fq.gz" -S ${SN}"_unmap-ec_metaplasmid_align.sam" -p 70;

###4 Comvert SAM to BAM and sort
nice -n 5 samtools view -bS ${SN}"_unmap-ec_metaplasmid_align.sam" -@ 70 | samtools sort - -o ${SN}"_unmap-ec_metaplasmid_align.bam" -@ 70; 

###5 index bam file
nice -n 5 samtools index ${SN}_unmap-ec_metaplasmid_align.bam

rm ${SN}"_unmap-ec_metaplasmid_align.sam";

#---

echo "script all done....step1"


done

####### Failed sample 6F
SPAdes=/bioinfo/SPAdes/SPAdes-3.15.3-Linux/bin/spades.py

nice -n 5 ${SPAdes} --pe1-1 6F_unmap-ec_1.fq.gz --pe1-2 6F_unmap-ec_2.fq.gz --metaplasmid -o 6F_unmap-ec_metaplasmid -t 70 --only-assembler


#######

SN="6F"

bowtie2-build ${SN}_unmap-ec_spades/scaffolds.fasta ${SN}_unmap-ec_spades/scaffolds

###3 Align to genome assembly
nice -n 5 bowtie2 -x ${SN}_unmap-ec_spades/scaffolds -1 ${SN}"_unmap-ec_1.fq.gz" -2 ${SN}"_unmap-ec_2.fq.gz" -S ${SN}"_unmap-ec_spades_align.sam" -p 70;

###4 Comvert SAM to BAM and sort
nice -n 5 samtools view -bS ${SN}"_unmap-ec_spades_align.sam" -@ 70 | samtools sort - -o ${SN}"_unmap-ec_spades_align.bam" -@ 70; 

###5 index bam file
nice -n 5 samtools index ${SN}_unmap-ec_spades_align.bam

rm ${SN}"_unmap-ec_spades_align.sam";


################
###############################################################
#  Remove Fosmid backbone sequence from the assembly 
################

find /home/RAWDATA/5.57.48.133/F21FTSEUHT0827_BACurkR/Clean/ -name "*_1.fq.gz" |sort|while read READ_FW;
do

FILEBASE=$(basename $READ_FW | cut -d_ -f1 );
DIRNM=$(dirname $READ_FW );
SN=${out_dir1}${FILEBASE}
echo $SN

qr=/home/REF/Fosmid/pcc1fos.fa

NCBIBLAST="/bioinfo/BLAST/ncbi-blast-2.9.0+/bin/"

#create DB
$NCBIBLAST/makeblastdb -in ${SN}_unmap-ec_metaplasmid/scaffolds.fasta -out ${SN}_unmap-ec_metaplasmid/scaffolds -input_type fasta -dbtype nucl

######################
######-- search db
nice -n 5 ${NCBIBLAST}blastn -query ${qr} \
-db ${SN}_unmap-ec_metaplasmid/scaffolds -num_threads 68 \
-max_target_seqs 1 -outfmt 6 -evalue 1e-05 > ${SN}_unmap-ec_metaplasmid/scaffolds-max.blastn.outfmt6


######
#awk '{print $2"\t"$7"\t"$8"\t"$9"-"$10}' ${SN}_unmap-ec_metaplasmid/scaffolds-max.blastn.outfmt6 | sort -k1,1 -k2,2n | bedtools merge -c 4 -o collapse | awk '{split($4,a,","); print $1"\t"$2"\t"$3"\t"a[1]}' > ${SN}_unmap-ec_metaplasmid/regions.bed
cat ${SN}_unmap-ec_metaplasmid/scaffolds-max.blastn.outfmt6 | awk '{print $2"\t"$9"\t"$10}' | awk ' {split( $0, a, " " ); asort( a ); for( i = 1; i <= length(a); i++ ) printf( "%s ", a[i] ); printf( "\n" ); }' | awk '{print $3"\t"$1"\t"$2"\t"$1"-"$2}' | sort -k2,2n -k3,3n | bedtools merge -c 4 -o collapse > ${SN}_unmap-ec_metaplasmid/regions.bed

######
cat ${SN}_unmap-ec_metaplasmid/regions.bed | awk '{ print $1"\t"$2"\t"$3}' | sort -k2,3n | xargs | awk '{print $1"\t"$2"\t"$6 }' > ${SN}_unmap-ec_metaplasmid/regions_crop.bed

#######
#Edit samples ( 25F,21F,18F ) with more than 2 ranges

###### Mask your regions with a zero character
bedtools maskfasta -mc @ -fi ${SN}_unmap-ec_metaplasmid/scaffolds.fasta -bed ${SN}_unmap-ec_metaplasmid/regions_crop.bed -fo ${SN}_unmap-ec_metaplasmid/scaffolds_masked.fasta

###### Replace the masked regions with no characters
sed 's/@//g' ${SN}_unmap-ec_metaplasmid/scaffolds_masked.fasta | awk '/^>/ {printf("%s%s\n",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}' > ${SN}_unmap-ec_metaplasmid/scaffolds_rmpc.fasta

###### 

done


#################

work_dir=/home/
out_dir1=${work_dir}Align-ecoli/

######

find /home/RAWDATA/ -name "*_1.fq.gz" |sort|while read READ_FW;
do

FILEBASE=$(basename $READ_FW | cut -d_ -f1 );
DIRNM=$(dirname $READ_FW );
SN=${out_dir1}${FILEBASE}
echo $SN

cd ${out_dir1}

#TransDecoder = Functional Annotation of Assembled Transcripts 
######
#wc -l ${SN}"_TransDecoder/scaffolds_rmpc.fasta.transdecoder.bed"

mkdir ${SN}_TransDecoder
cd ${SN}_TransDecoder

TRANSDECODER_HOME="/bioinfo/TransDecoder-TransDecoder-v5.5.0/"

#######
#Identification of likely protein-coding regions in transcripts

$TRANSDECODER_HOME/TransDecoder.LongOrfs -t ${SN}_unmap-ec_metaplasmid/scaffolds_rmpc.fasta
$TRANSDECODER_HOME/TransDecoder.Predict -t ${SN}_unmap-ec_metaplasmid/scaffolds_rmpc.fasta

#######

done

echo "script all done...."

