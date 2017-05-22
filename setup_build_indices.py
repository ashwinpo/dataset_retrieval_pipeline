''' Generate build_indices.sh
	@author: Wei Wei
	Updated on May 20, 2017
'''

import os, re, sys
from constants import code_dir

if __name__=="__main__":
	schema_dir = sys.argv[1]

	fin = file(os.path.join(code_dir, "build_indices_template.sh")).read().split("\n")
	new = []
	for line in fin:
		line = re.sub("XXXX", schema_dir, line)
		new.append(line)

	fout = file(os.path.join(schema_dir,"build_indices.sh"),"w")
	fout.write("\n".join(new))
