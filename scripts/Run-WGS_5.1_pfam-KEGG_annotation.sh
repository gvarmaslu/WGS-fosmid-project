#!/bin/bash -l

echo "PFAM and KEGG analysis"

#./Run-WGS_5.1_pfam-KEGG_annotation.sh > Run-WGS_5.1_pfam-KEGG_annotation.sh.log 2>&1

###########################################################
#################
#1.4 Domain/profiles homology searches
#1.4.1 Pfam database

#################
#### Make Pfam DB

wget http://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam34.0/Pfam-A.hmm.gz
gunzip Pfam-A.hmm.gz
hmmpress Pfam-A.hmm

###########################################################
# call all samples and Pars pep sequence 
cd /RASTtk_all_metaplasmid_anno/

rm Merge_allsamp_anno_pep.fa

find /RAWDATA/ -name "*_1.fq.gz" |sort|while read READ_FW;
do

FILEBASE=$(basename $READ_FW | cut -d_ -f1 );
DIRNM=$(dirname $READ_FW );
#SN=${out_dir1}${FILEBASE}
SN=${FILEBASE}
echo ${SN}

#ls ${SN}_anno_max-10.tsv

cat ${SN}_anno.tsv | sed '1d' | awk -F'\t' '$13 != "."' | awk -F"\t" '{print ">"'${SN}'"F__"$4"\n"$13}' >> Merge_allsamp_anno_pep.fa

done

###########################################################

#### Search pfam DB
#hmmscan --cpu 5 --domtblout TrinotatePFAM.out ~/RNAseq_assembly_annotation/assembly_annotation/database/trinotate_database/Pfam-A.hmm Trinity_200.fa.transdecoder.pep

hmmscan --cpu 69 --domtblout Merge_allsamp_anno_pep_PFAM.out /DATABASE/PFAM/Pfam34.0/Pfam-A.hmm Merge_allsamp_anno_pep.fa

######
# filter PFAM output file
#head Merge_allsamp_anno_pep_PFAM.out | awk -F" " '{print $4"\t"$2"\t"$1}' 

###### get accession # Cluster 2nd column based on 1st column
cat Merge_allsamp_anno_pep_PFAM.out | sed '1,3d' | sed '/^#/d' | awk -F" " '{print $4"\t"$2}' | awk ' !(a[$1]) {a[$1]=$0} a[$1] {w=$1; $1=""; a[w]=a[w] $0} END {for (i in a) print a[i]}' FS="\t" OFS="; " | awk '{$2=""; print $0}' FS=";" OFS=";" | sed s'/;;/;/'g > Merge_allsamp_anno_pep_PFAM_clust_acc.out

###### get target name # Cluster 2nd column based on 1st column
cat Merge_allsamp_anno_pep_PFAM.out | sed '1,3d' | sed '/^#/d' | awk -F" " '{print $4"\t"$1}' | awk ' !(a[$1]) {a[$1]=$0} a[$1] {w=$1; $1=""; a[w]=a[w] $0} END {for (i in a) print a[i]}' FS="\t" OFS="; " | awk '{$2=""; print $0}' FS=";" OFS=";" | sed s'/;;/;/'g > Merge_allsamp_anno_pep_PFAM_clust_t-name.out

###### get target name # Cluster 2nd column based on 1st column
cat Merge_allsamp_anno_pep_PFAM.out | sed '1,3d' | sed '/^#/d' | awk -F" " '{print $4"\t"$23,$24,$25,$26,$27}' | awk ' !(a[$1]) {a[$1]=$0} a[$1] {w=$1; $1=""; a[w]=a[w] $0} END {for (i in a) print a[i]}' FS="\t" OFS="; " | awk '{$2=""; print $0}' FS=";" OFS=";" | sed s'/;;/;/'g > Merge_allsamp_anno_pep_PFAM_clust_acc-desc.out

######

echo "script all done...."


