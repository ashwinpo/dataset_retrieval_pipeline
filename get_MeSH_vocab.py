'''
    Build s vocabulary of MeSH terms and associated entry terms.

    Created on May 31, 2016
    Updated on Nov 2, 2016
    @author Wei Wei
'''

import os, re, time, sys
from constants import *
def analyze(inFile, outFile):

    vocab = [] # [human, confounding varialbe]
    
    fin = file(inFile).readlines()
    for line in fin:
        term = ''
        if line.startswith("MH = "):
            term = re.findall("MH = (.*?)[\n]",line)[0]
        if line.startswith("ENTRY = "):
            term = re.findall("ENTRY = (.*?)[\n|\|]", line)[0]
        if line.startswith("PRINT ENTRY ="):
            term = re.findall("PRINT ENTRY = (.*?)[\n|\|]", line)[0]
        term = filter(None, term.split(" "))
        vocab.append(" ".join(term).lower())
    vocab = filter(None, vocab)
    vocab = list(set(vocab))
    vocab.sort()

    fout = file(outFile,"w")
    fout.write("\n".join(vocab))


if __name__ == "__main__":
    raw_mesh_file = sys.argv[1]# os.path.join(utils_dir,"d2016.bin")
    utils_dir = sys.argv[2]
    # = os.path.join(data_base_dir, "utilities")
    # if not os.path.exists(utils_dir):
    #     os.makedirs(utils_dir)
    vocab_file = os.path.join(utils_dir, "mesh_and_entry_vocab.txt")

    t0=time.time()
    analyze(raw_mesh_file, vocab_file)
    t1=time.time()
    print "time ", t1-t0
