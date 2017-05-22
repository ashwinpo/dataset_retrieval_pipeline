'''
	Analyze collected additional fields and citation pmids. Count available PMIDs.
	05/03/2017
	@author: Wei Wei
'''

import os

def get_pmids(indir):
	pmid_list = []
	for doc in os.listdir(indir):
		fin = file(os.path.join(indir, doc)).read().split("\n")
		for val in fin:
			dsid_pmid_pair = val.split(":")
			if len(dsid_pmid_pair)>1:
				pmids = dsid_pmid_pair[1].strip().split(";")
				pmid_list.extend(pmids)
	return pmid_list

if __name__=="__main__":
	add_info_dir = "../data/additional_fields"
	add_field_dsID_list = []
	add_cit_dsID_list = []

	for subdir in os.listdir(add_info_dir):
		wk_dir = os.path.join(add_info_dir, subdir) ## current sub dir
		add_field_dir = os.path.join(wk_dir, "additional_fields") ## folder for additional fields
		add_cit_dir = os.path.join(wk_dir, "mappings") ## folder for associated citations
		## get additional fields
		if not os.path.exists(add_field_dir):
			pass
		else:
			add_field_dsID_list.extend(os.listdir(add_field_dir))
		## get citation pmids
		if not os.path.exists(add_cit_dir):
			pass
		else:
			pmids = get_pmids(add_cit_dir)
			add_cit_dsID_list.extend(pmids)
	print "add_field_dsID_list #: ", len(add_field_dsID_list), len(set(add_field_dsID_list)) ## 158,842 unique datasets have additional fields
	print "add_cit_dsID_list #: ", len(add_cit_dsID_list), len(set(add_cit_dsID_list)) ## 196,078 unique pmids

	## save unique pmids
	pmid_list = list(set(add_cit_dsID_list))
	fname = "all_primarily_associated_citation_pmids.txt"
	outval = "\n".join(pmid_list)
	fout = file(fname, "w")
	fout.write(outval)


