#!/bin/bash -l

echo "BLAST for CAZyDB"

#./Run-WGS_3.1_BLAST-CAZyDB.sh > Run-WGS_3.1_BLAST-CAZyDB.sh.log 2>&1

#######

###############################################################
#  BLAST search

find /RAWDATA/ -name "*_1.fq.gz" |sort|while read READ_FW;
do

FILEBASE=$(basename $READ_FW | cut -d_ -f1 );
DIRNM=$(dirname $READ_FW );
#SN=${out_dir1}${FILEBASE}
SN=${FILEBASE}
echo $SN

######################
######-- make query files
#cat ${SN}".txt" | awk -F"\t" '{ print ">"$4"\n"$(NF)}' > ${SN}"_pep.fa"

qr=${SN}"_pep.fa"
#qr=${SN}"_scaffolds_rmpc.fasta.transdecoder.pep"

NCBIBLAST="/bioinfo/BLAST/ncbi-blast-2.9.0+/bin/"

#create BLAST-DB before running the blast search 
#$NCBIBLAST/makeblastdb -in /REF/CAZyDB/CAZyDB.07292021.fa -out /REF/CAZyDB/CAZyDB.07292021 -input_type fasta -dbtype prot

######################
######-- search db # -max_target_seqs 1  -max_hsps 1
<<COMM
nice -n 5 ${NCBIBLAST}blastp -query ${qr} \
-db /REF/CAZyDB/CAZyDB.07292021 -num_threads 70 \
-max_target_seqs 1 -max_hsps 1 -outfmt 6 -evalue 1e-05 > ${SN}_CAZyDB.blastp_allmax.out

COMM

######-- search db # -max_target_seqs 1  -max_hsps 1
nice -n 5 ${NCBIBLAST}blastp -query ${qr} \
-db /REF/CAZyDB/CAZyDB.07292021 -num_threads 70 \
-max_target_seqs 10 -max_hsps 10 -outfmt 6 -evalue 1e-05 > ${SN}_CAZyDB.blastp_max-t5_max-h5.out

######-- search db # -max_target_seqs 1  -max_hsps 1
nice -n 5 ${NCBIBLAST}blastp -query ${qr} \
-db /REF/CAZyDB/CAZyDB.07292021 -num_threads 70 \
-max_target_seqs 10 -max_hsps 10 -outfmt 6 -evalue 1e-05 > ${SN}_CAZyDB.blastp_max-t10_max-h10.out

######

done

