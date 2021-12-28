#!/bin/bash -l

echo "Assembly plasmid"

#./Run-WGS_2.1_assembly-plasmid-metaplasmid.sh > Run-WGS_2.1_assembly-plasmid-metaplasmid.sh.log 2>&1

##########################################################
###########################################################
# Remove duplicate reads with cd-hit-dup ( CD-HIT )
################
work_dir=/home/
in_dir=${work_dir}Align-fosmid-ecoli_cdhit/
mkdir -p ${work_dir}Assem-spades-plasmid/
out_dir1=${work_dir}Assem-spades-plasmid/
cd ${out_dir1}

####
find ${in_dir} -name "*_R1.fq" |sort|while read READ_FW;
do

cd ${out_dir1}

FILEBASE1=$(basename $READ_FW | cut -d_ -f1 );
FILEBASE=$(basename $READ_FW | cut -d_ -f1 );
SN1=${in_dir}${FILEBASE1}
SN=${out_dir1}${FILEBASE}
echo $SN1
echo $SN 

###############################################################
#  Assembly with SPAdes
################
#https://github.com/ablab/spades#bgc

SPAdes=/bioinfo/SPAdes/SPAdes-3.15.3-Linux/bin/spades.py
MPS=/bioinfo/SPAdes/SPAdes-3.15.3-Linux/bin/metaplasmidspades.py


#nice -n 5 ${MPS} --pe1-1 10F_unmap-fo_unmap-ec_1.fq.gz --pe1-2 10F_unmap-fo_unmap-ec_2.fq.gz --metaplasmid -o 10F_metaplasmid-spades -t 70

nice -n 5 ${SPAdes} --pe1-1 ${SN1}_cdhit_R1.fq --pe1-2 ${SN1}_cdhit_R2.fq --metaplasmid -o ${SN}_metaplasmid-spades -t 70

nice -n 5 ${SPAdes} --pe1-1 ${SN1}_cdhit_R1.fq --pe1-2 ${SN1}_cdhit_R2.fq --plasmid -o ${SN}_plasmid-spades -t 70

#cd ${SN}_metaplasmid-spades
#cd ${SN}_plasmid-spades
################
#https://github.com/ablab/plasmidVerify
#plasmidVerify: plasmid contig verification tool
#./plasmidverify.py 
#		-f Input fasta file
#        -o output_directory 
#        --hmm HMM    Path to Pfam-A HMM database

#nice -n 5 /bioinfo/plasmidVerify/plasmidVerify/plasmidverify.py -f ${SN}"_metaplasmid-spades/scaffolds.fasta" -o ${SN}"_metaplasmid-spades/scaffolds_plasmidverify" --hmm /DATABASE/PFAM/Pfam-A.hmm -t 70
#nice -n 5 /bioinfo/plasmidVerify/plasmidVerify/plasmidverify.py -f ${SN}"_plasmid-spades/scaffolds.fasta" -o ${SN}"_plasmid-spades/scaffolds_plasmidverify" --hmm /DATABASE/PFAM/Pfam-A.hmm -t 70


################
#http://quast.sourceforge.net/install.html
#Assembly evaluation # SPAdes statistics
#QUAST
#QUAST=/bioinfo/QUAST/quast-5.0.1/quast.py
#MQUAST=/bioinfo/QUAST/quast-5.0.1/metaquast.py
######
#conda activate quest
#python ./quast.py [options] <files_with_contigs
#quast.py -o QUAST_out -t 70 contigs.fasta 
#python2.7 $QUAST -o MQUAST_unmap-ec_metaplasmid_unmap-pls -t 70 *_unmap-ec_metaplasmid/scaffolds.fasta
python2.7 $QUAST -o QUAST_out -t 70 *_plasmid-spades/contigs.fasta 

######

cd ${out_dir1}

### remove files
rm ${SN}_1.fq
rm ${SN}_2.fq

rm ${SN}_cdhit_R1.fq
rm ${SN}_cdhit_R2.fq

rm ${SN}*_R1.fq.clstr
rm ${SN}*_R1.fq2.clstr

######

done 


echo "script all done....all"

#######

