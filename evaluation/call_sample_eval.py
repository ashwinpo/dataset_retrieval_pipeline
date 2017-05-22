'''
    Call sample_eval.pl to compute infNDCG and infAP
'''


import subprocess, sys, os
from constants import *

if __name__=="__main__":
    command=os.path.join(code_dir,"evaluation","eval_tools/sample_eval.pl")
    qrel = os.path.join(code_dir,"evaluation", "biocaddie_qrels.txt")
    hits = sys.argv[1]
    subprocess.call(["perl", command, "-q", qrel, hits])

