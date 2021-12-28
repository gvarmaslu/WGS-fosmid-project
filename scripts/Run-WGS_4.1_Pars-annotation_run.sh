#!/bin/bash -l

echo "Parse annotations"

###############################################################
#  Annotate all samples 

find /RAWDATA/ -name "*_1.fq.gz" |sort|while read READ_FW;
do

FILEBASE=$(basename $READ_FW | cut -d_ -f1 );
DIRNM=$(dirname $READ_FW );
#SN=${out_dir1}${FILEBASE}
SN=${FILEBASE}
echo ${SN}


######################
######-- run python script to run on all samples 

python Run-WGS_4.0_Pars-annotation.py ${SN}.txt ${SN}_anno_max-10.tsv /RASTtk_all_metaplasmid/

######

done

######################
######
FILENAME="Sort-uniprot-IDs"

######

cd /RASTtk_all_metaplasmid_anno_pars/

#cat sel_all_fosmids.tsv | awk -F"\t" '{split( $1, a, " " );print ">"a[2]"_"$7"\n"$4}' > sel_all_fosmids_pars_IDs.fa
#cat sel_all_fosmids.tsv | awk -F"\t" '{print ">"$1"_"$5"_"$7"\n"$4}' > sel_all_fosmids_pars.fa
#cat sel_all_fosmids.tsv | awk -F"\t" '{split( $1, a, " " );split( $5, b, "|" );print ">"a[2]"_"$b[1]"\n"$4}'
#| sed 's/.1|/_/g' | sed 's/|//g'
#cat sel_all_fosmids.tsv | awk -F"\t" '{split($1, a, " " ); print ">"a[2]"_"$5"\n"$4}' 

cat sel_all_fosmids.tsv | awk -F"\t" '{split($1, a, " " ); print a[2]"_"$5}' | sort -u > ${FILENAME}.txt
cat sel_all_fosmids.tsv | awk -F"\t" '{split($1, a, " " ); print ">"a[2]"_"$5"\n"$3}' > all_uniprot-IDs_CDS.fa

sed -i s'/_CAZyDB-ID//g' ${FILENAME}.txt

#### empty files
rm ${FILENAME}-all_AA.fa
rm ${FILENAME}-all_CDS.fa

####

for i in $(cat ${FILENAME}.txt)
do

grep ''$i'' all_uniprot-IDs_CDS.fa -m1 -A1 >> ${FILENAME}-all_CDS.fa

done

cat ${FILENAME}.txt | awk '{split($1, a, "." );split(a[2], b, "|" );split(a[1], c, "_" ); print $1"\t"c[1]"\t"c[2]"\t"b[2]}' | cat -n > ${FILENAME}_split.tsv


#####
# CD-HIT-EST
cd-hit-est -i ${FILENAME}-all_CDS.fa -o ${FILENAME}-all_CDS.95.fa -c 0.95 -M 0 -T 0

#cat ${FILENAME}-all_CDS.95.fa.clstr | awk ' /Cluster/ { no+=1;}; !/Cluster/ { id=substr($3, 2, length($3)-4); printf("%s\t%s\n", no, id) }' > ${FILENAME}-all_CDS.95.fa.clstr_pars.tsv

cat ${FILENAME}-all_CDS.95.fa.clstr | awk ' /Cluster/ { no+=1;}; !/Cluster/ { id=substr($3, 2, length($3)-4); printf("%s\t%s\n", no, id) }' | awk ' !(a[$1]) {a[$1]=$0} a[$1] {w=$1; $1=""; a[w]=a[w] $0} END {for (i in a) print a[i]}' FS="\t" OFS="\t" > ${FILENAME}-all_CDS.95.fa.clstr_pars_merge.tsv

########
# filtered list 
# CD-HIT-EST
#cd-hit-est -i GH_sequences_nucl.fa -o GH_sequences_nucl.95.fa -c 0.95 -M 0 -T 0

##### Remove duplicated uniprot IDs  and keeping unique ones per fosmid sequence
cat ${FILENAME}-all_CDS.95.fa.clstr_pars_merge.tsv | cut -f2- | grep "GH" | awk '{ delete a; for (i=1; i<=NF; i++) a[$i]++; n=asorti(a, b); for (i=1; i<=n; i++) printf b[i]";"; print "" }' | sort -k1 -g > ${FILENAME}-all_CDS.95.fa.clstr_pars_merge_rmdupIDs.tsv

##### Retrieve complete sequence using IDs and append full IDs
rm ${FILENAME}-all_CDS.95.fa.clstr_pars_merge_rmdupIDs.fa

for i in $(cat ${FILENAME}-all_CDS.95.fa.clstr_pars_merge_rmdupIDs.tsv)
do
ii=$(echo "$i" | cut -d';' -f1)
echo ">Fosmid_"$i >> ${FILENAME}-all_CDS.95.fa.clstr_pars_merge_rmdupIDs.fa
grep "$ii" ${FILENAME}-all_CDS.95.fa -A 1 | grep -v ">" >> ${FILENAME}-all_CDS.95.fa.clstr_pars_merge_rmdupIDs.fa

done

##### Clean-up files 

rm all_uniprot-IDs_CDS.fa
