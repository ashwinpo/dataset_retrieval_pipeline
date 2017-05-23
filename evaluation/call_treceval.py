'''
    Call TREC_EVAL to compute NDCG@10
'''

import subprocess, os, sys
cwd =os.path.dirname(os.path.abspath(__file__))
from constants import *

if __name__=="__main__":

    command=os.path.join(code_dir,"evaluation","eval_tools/trec_eval.9.0/trec_eval")
    std_file = os.path.join(code_dir,"evaluation","./biocaddie_qrels_4columns.txt")
    res_file = sys.argv[1]
    subprocess.call([command, '-m', 'ndcg_cut',std_file, res_file])