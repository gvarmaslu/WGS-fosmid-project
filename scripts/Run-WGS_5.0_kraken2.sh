#!/bin/bash -l

echo "Taxonomic classicfication with Kraken2"

#./Run-WGS_5.0_kraken2.sh > Run-WGS_5.0_kraken2.sh.log 2>&1

##########################################################

#################
# run KRAKEN2
#https://github.com/bhattlab/kraken2_classification
#git clone https://github.com/bhattlab/kraken2_classification.git

#1.0 Usage

# Example run:
#kraken2 --use-names --threads 4 --db PATH_TO_DB_DIR --report example.report.txt example.fa > example.kraken
#kraken2 --use-names --threads 4 --db minikraken2_v2_8GB_201904_UPDATE --fastq-input --report evol1 --gzip-compressed --paired ../mappings/evol1.sorted.unmapped.R1.fastq.gz ../mappings/evol1.sorted.unmapped.R2.fastq.gz > evol1.kraken

#mkdir 5.1_kraken2_run
#cd 5.1_kraken2_run

filepath="./RASTtk_all_metaplasmid_anno_pars/"
filename="Sort-uniprot-IDs-all_CDS.95.fa.clstr_pars_merge_GH-rmdupIDs"

# Kraken2 Database built from the refseq bacteria, archaea, and viral libraries

KRAKEN2_DEFAULT_DB=/bioinfo/kraken2/kraken2-2.0.8-beta/kraken2_dbs/minikraken2_v1_8GB

kraken2 --use-names --threads 70 --db $KRAKEN2_DEFAULT_DB --report ${filename}_evol1.report.txt ${filepath}${filename}.fa > ${filename}_evol1.kraken.tsv

#######
#1.1 Investigate taxa
# bracken -d PATH_TO_DB_DIR -i kraken2.report -o bracken.species.txt -l S

#/bioinfo/kraken2/Bracken/bracken -d $KRAKEN2_DEFAULT_DB -i ${filename}_evol1.report.txt -o ${filename}_bracken.species_S.tsv -l S

#######
#2.0 Centrifuge
#2.1 Installation

#conda create --yes -n centrifuge centrifuge
conda activate centrifuge

cd centrifuge/

#######
#2.2 Usage
#Example run 
#centrifuge -x p_compressed+h+v -1 example.1.fq -2 example.2.fq -U single.fq --report-file report.txt -S results.txt

centrifuge -x p_compressed+h+v -f ${filepath}${filename}.fa --report-file ${filename}_evol1-centrifuge-report.txt -S ${filename}_evol1-centrifuge-results.txt

#######
#2.3 Generate Kraken-like report
#Example run 
#centrifuge-kreport -x p_compressed+h+v evolved-6-R1-results.txt > evolved-6-R1-kreport.txt

centrifuge-kreport -x p_compressed+h+v ${filename}_evol1-centrifuge-results.txt > ${filename}_evol1-centrifuge-kreport.txt

conda deactivate

#######

#3.0 Visualisation (Krona)

#conda create --yes -n krona krona
conda activate krona

####### Setup krona environment
#rm -fr ~/anaconda3/envs/krona/opt/krona/taxonomy/
#mkdir -p ~/krona/taxonomy
#ln -s ~/krona/taxonomy ~/anaconda3/envs/krona/opt/krona/taxonomy/

#3.1 Build the taxonomy
#ktUpdateTaxonomy.sh ~/krona/taxonomy

cd ../

####### Parse kraken2 output file for krona report 
#3.2 Kraken2 results Visualise with Krona 

cat ${filename}_evol1.kraken.tsv | awk -F"\t" '{split($3,a,"taxid ");split(a[2],b,")"); print $2"\t"b[1]}' > ${filename}_evol1.kraken.krona.tsv

ktImportTaxonomy ${filename}_evol1.kraken.krona.tsv

mv taxonomy.krona.html ${filename}_taxonomy.krona.html

####### Parse Centrifuge output file for krona report
#3.3 Centrifuge results Visualise with Krona 

cd centrifuge
cat ${filename}_evol1-centrifuge-results.txt | cut -f 1,3 > ${filename}_evol1-centrifuge-results.krona.tsv

ktImportTaxonomy ${filename}_evol1-centrifuge-results.krona.tsv

mv taxonomy.krona.html ${filename}_taxonomy.krona.html

########

conda deactivate

#######

echo "script all done...."


