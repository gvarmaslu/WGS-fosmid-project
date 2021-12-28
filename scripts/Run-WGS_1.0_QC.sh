#!/bin/bash -l


echo "Run script for Cleaning and QC"

#./Run-WGS_1.0_QC.sh > Run-WGS_1.0_QC.sh.log 2>&1

#1. Raw Data QC Assessment
work_dir=/home/

mkdir -p ${work_dir}1.0_FastQC/
out_dir1=${work_dir}1.0_FastQC/

mkdir -p ${work_dir}1.1_MultiQC/
out_dir2=${work_dir}1.1_MultiQC/


cd ${work_dir}

for f in `ls /home/RAWDATA/*/*_1.fq.gz`; do

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

echo "Done script..."

