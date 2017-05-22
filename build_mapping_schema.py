''' Create mapping schemas for each database
	@author: Wei Wei
	Updated on May 20, 2017
'''
import os, re, sys
from constants import code_dir
if __name__=="__main__":
	schema_dir = sys.argv[1] ## e.g index_std_ext_settings
	index_suffix = sys.argv[2] ## e.g. std_ext
	if not os.path.exists(schema_dir):
		os.makedirs(schema_dir)

	template_dir = os.path.join(code_dir, "schema_template") 

	for template_file in os.listdir(template_dir):
		temp = file(os.path.join(template_dir, template_file)).read().split("\n")
		for i in range(3):
			temp[i] = re.sub("XXXX",index_suffix,temp[i])
		schema = "\n".join(temp)
		fout = file(os.path.join(schema_dir,template_file),"w")
		fout.write(schema)