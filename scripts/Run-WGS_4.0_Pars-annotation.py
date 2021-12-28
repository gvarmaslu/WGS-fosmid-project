#!/usr/bin/python


"""
#Script to Pars and merge annotations 

#####------Inputs-------
# Run-WGS_4.0_Pars-annotation.py INPUT=Inputfile OUTPUT=Outputfile DIR=Directory-fullpath

#python Run-WGS_4.0_Pars-annotation_Cazy.py 9F.txt 9F_anno_max-10.tsv /RASTtk_all_metaplasmid/

#############################################------
#cut -d";" --output-delimiter=$'\t' -f3,4,5,7,8,11 | 

truncate -s 0 Thaliana_PIDs_anno

####------

"""

import sys
import re
import subprocess
from subprocess import *
from subprocess import call


"""
#Query_ID, Subject_ID, %Identity, Alignment_length, Mismatches, Gap_opens, Q.start, Q.end, S.start, S.end, E-value, Bit-score
#Query_ID	Subject_ID	%Identity	Alignment_length	Mismatches	Gap_opens	Q.start	Q.end	S.start	S.end	E-value	Bit-score
"""

class fileHandler:
	def __init__(self):
		self.data = []
		#print "Calling fileHandler constructor"
	def open_file(self,readfl):
		self.rfile = open(readfl,'r').readlines()
		return self.rfile
	def write_file(self,writefl):
		self.wfile = open(writefl,'w')
		return self.wfile

class SearchDB(fileHandler):

	def __init__(self):
		self.data = []
		from collections import defaultdict
		self.ident_ranges_HMBM = defaultdict(list)

	def Search_ReMM(self,readfl1,outfl1,workdir):
		"""
		Calling Search local DB
		"""
		def blastout_pars(AnnoPars):
			qstart_end=str("Q:"+"-".join(AnnoPars[6:8]))
			sstart_end=str("S:"+"-".join(AnnoPars[8:10]))
			AnnoPars_merge= str(qstart_end+","+sstart_end+";"+AnnoPars[2]+"%ID;E:"+AnnoPars[10])	
			grepout = str(AnnoPars[1]+"\t"+AnnoPars_merge)
			return grepout

		def srchdb_blastout(GName,FPATH):
			try:
				True
				cmdFls1 = "LANG=C grep -w '"+str(GName)+"' "+str(FPATH)+""
				cmdFls2 =  subprocess.check_output(cmdFls1, shell=True)
				AnnoPars = cmdFls2.strip().decode().split("\t")
				AnnoParsall = cmdFls2.strip().decode().split("\n")
				listall=[]
				for ech in AnnoParsall:
					grepout = blastout_pars(ech.split("\t"))
					listall.append(grepout)
				grepout = str("\n".join(listall))
				#print(grepout)
			except:
				False
				grepout = str(".")
			return grepout

		def srchdb_header(GName,FPATH):
			try:
				True
				cmdFls1 = "LANG=C grep -w -P '"+str(GName)+"\t' "+str(FPATH)+""
				cmdFls2 =  subprocess.check_output(cmdFls1, shell=True)
				AnnoPars = cmdFls2.strip().decode().split("\t")
				grepout = "\t".join(AnnoPars)
			except:
				False
				grepout = str(".")
			return grepout

		with open(workdir+readfl1,'r') as f1, open(workdir+outfl1,'w') as output:
			first_line0 = f1.readline().strip().split("\t")
			first_lines = f1.readlines()
			Geneanno_blasthead= str("Q=Query:start-end,S=Subject:start-end;%ID=%Identity;E=E-value")
			output.write(str(str("\t".join(first_line0))+"\t"+"CAZyDB-ID"+"\t"+"CAZyDB_BLAST:"+Geneanno_blasthead+"\t"+"CAZyDB-ID:description"+"\t"+"MEROPS-ID"+"\t"+"MEROPS_BLAST:"+Geneanno_blasthead+"\t"+"MEROPS-ID:description"+"\n"))
			for lns in first_lines:
				lns_sp =  lns.strip().split("\t")
				lns_sp2 =  lns_sp[3]
				DIR_CAZy="/REF/CAZyDB/"
				DIR_MEROPS="/REF/MEROPS/"
				samnum = readfl1.split(".")[0]

				FPATH1=workdir+samnum+"_CAZyDB.blastp_max-t10_max-h10.out"
				FPATH2=workdir+samnum+"_MEROPS.blastp_allmax.out"

				FPATH_head1=DIR_CAZy+"CAZyDB.07302020.fam-activities.txt"
				FPATH_head2=DIR_MEROPS+"protease_hdr.txt"

				#####
				# Gene annotation 
				#####
				Anno_out1 = srchdb_blastout(lns_sp2,FPATH1)
				if Anno_out1.split()[0] != ".":
					ii=0
					for ech in Anno_out1.split("\n"):
						C_code = ech.split("\t")[0].split("|")[1].split("_")[0]
						Anno_out_head1_pars = srchdb_header(C_code,FPATH_head1)
						Anno_out_head1 = str(":".join(Anno_out_head1_pars.split("\t")))
						output.write(str("\t".join(lns_sp)+"\t"+Anno_out1.split("\n")[ii]+"\t"+Anno_out_head1+"\n"))
						ii+=1
				else:
					Anno_out_head1 = "."
					output.write(str("\t".join(lns_sp)+"\t"+Anno_out1+"\t"+Anno_out_head1+"\n"))

		print("Done seach for ...")
		return None

clF1 = SearchDB().Search_ReMM(sys.argv[1],sys.argv[2],sys.argv[3])


