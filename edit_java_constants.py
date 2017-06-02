import os, re, sys
from constants import *

wkdir = os.path.join(code_dir, "rerank","PSD")

query_file = sys.argv[1]
ret_dir = sys.argv[2]
out_dir = sys.argv[3]

const_file = os.path.join(wkdir,"Constants.java")
fin = file(const_file).readlines()

fin[4] = re.sub('\"(.*)\"','\"%s\"'%query_file, fin[4])

fin[6] = re.sub('\"(.*)\"','\"%s\"'%ret_dir, fin[6])

fin[8] = re.sub('\"(.*)\"','\"%s\"'%out_dir, fin[8])


fout = file(os.path.join(wkdir,"Constants.java"),"w")
fout.writelines(fin)
