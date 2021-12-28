#!/bin/bash -l


echo "Run script for Cleaning and QC2"

#./Run-WGS_3.0_QC.sh > Run-WGS_3.0_QC.sh.log 2>&1

#1. Raw Data QC Assessment
work_dir=/

mkdir -p ${work_dir}FastQC/
out_dir1=${work_dir}FastQC/

mkdir -p ${work_dir}MultiQC/
out_dir2=${work_dir}MultiQC/


cd ${work_dir}

for f in `ls /2.2_Align-fosmid-ecoli/*_1.fq.gz`; do

DIR=$(dirname $f)
BASEFL=$(basename $f )
BASEFL_CP=$(basename $f | cut -d_ -f1 )
#SID=$(basename $f | cut -d- -f1 )

echo "Dir_ID:" ${DIR}
echo "Sample_filepath:" ${BASEFL}
echo "Sample_ID_trim:" ${BASEFL_CP}

####
#Command to run fastqc 
nice -n 5 find ${DIR} -name '*.gz' | xargs fastqc -o ${out_dir1} -t 70

done

####
# Command to run multiqc on FastQC files

conda activate py3.7

multiqc ${out_dir1} -o ${out_dir2}

conda deactivate

####

#################################################################################

####--- stats check

#
work_dir=/
cd ${work_dir}

for f in `ls /Align-fosmid-ecoli/*_1.fq.gz`; do

DIR=$(dirname $f)
BASEFL=$(basename $f )
BASEFL_CP=$(basename $f | cut -d_ -f1 )

#echo ${BASEFL_CP}" "$(cat /2.3_Assem/${BASEFL_CP}_TransDecoder/${BASEFL_CP}_contigs_cdhit.fa.transdecoder.bed | cut -f1 | sort -u | wc -l)

cat /Assem/${BASEFL_CP}_TransDecoder/${BASEFL_CP}_contigs_cdhit.fa.transdecoder.bed | cut -f1 | sort -u | wc -l


done 



echo "Done script..."

