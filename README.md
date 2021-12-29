
### Whole Genome Sequencing (WGS) of fosmid data analysis


##### This workflow was developed in a Linux environment, before running these scripts one should install all dependent packages/software and adopt working environment paths

> 1.0 
* Copy this project to your local directory and access script directory

```
git clone https://github.com/gvarmaslu/WGS-fosmid-project

cd WGS-fosmid-project/scripts/

```

* Run script for Cleaning and QC1

```
bash Run-WGS_1.0_QC.sh > Run-WGS_1.0_QC.sh.log 2>&1
```

> 2.0 
* Mapped with Ecoli and processed un-mapped reads for assembly

```
bash Run-WGS_2.0_Align-ecoli-assembly.sh > Run-WGS_2.0_Align-ecoli-assembly.sh.log 2>&1
```

> 2.1 
* De-novo assembly made with SPAdes "metaplasmid" algorithm 

```
bash Run-WGS_2.1_assembly-plasmid-metaplasmid.sh > Run-WGS_2.1_assembly-plasmid-metaplasmid.sh.log 2>&1
```
 
> 3.0 
* Run script for Cleaning and QC2

```
bash Run-WGS_3.0_QC.sh > Run-WGS_3.0_QC.sh.log 2>&1
```

> 3.1 
* BLAST for CAZyDB and MEROPS

```
bash Run-WGS_3.1_BLAST-CAZyDB.sh > Run-WGS_3.1_BLAST-CAZyDB.sh.log 2>&1
```

> 4.0 
* Script to merge annotations for each sample

```
### Run-WGS_4.0_Pars-annotation.py INPUT=Inputfile OUTPUT=Outputfile DIR=Directory-fullpath
python Run-WGS_4.0_Pars-annotation.py 9F.txt 9F_anno.tsv /PATH-TO-WORKING-DIR/
```

> 4.1 
* Script to run annotations for all samples, parse output files and run Clustering analysis with CD-HIT. This script also helps to remove plasmid backbone sequence and to keep insert sequence alone for further downstream analysis

```
bash Run-WGS_4.1_Pars-annotation_run.sh > Run-WGS_4.1_Pars-annotation_run.sh.log 2>&1
```

> 5.0 
* Taxonomic classicfication with Kraken2 and visualization with Krona

```
bash Run-WGS_5.0_kraken2.sh > Run-WGS_5.0_kraken2.sh.log 2>&1
```

> 5.1 
* PFAM and KEGG analysis

```
bash Run-WGS_5.1_pfam-KEGG_annotation.sh > Run-WGS_5.1_pfam-KEGG_annotation.sh.log 2>&1
```

