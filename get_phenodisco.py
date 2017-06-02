'''
    Follow https://qbox.io/blog/building-an-elasticsearch-index-with-python
    Build a ES index using provided data, using analyzers, stemmers, etc
    Index datasets according to the source databases

    Updated on 05/16/2017
    @author Wei Wei
'''
import json, cPickle, time, os, sys, subprocess
from constants import *
import multiprocessing as mp

data_dir = os.path.join(data_base_dir,"datamed_json")
outdir = os.path.join(data_base_dir,"phenodisco_raw")
if not os.path.exists(outdir):
    os.makedirs(outdir)
def worker(docList):
    for fname in docList:
        fullpath = os.path.join(data_dir, fname)
        text = file(fullpath).read()#.lower()
        try:
            raw_dat = json.loads(text)
            idx = raw_dat['REPOSITORY'].lower()
            if idx.startswith("phenodisco"):
                subprocess.call(["cp",fullpath,os.path.join(outdir,fname)])
        except Exception as e:
            print fname
            print e

if __name__=="__main__":
    docList = os.listdir(data_dir)
    chunksize = len(docList)/10

    docidx=0
    jobs=[]
    while docidx<len(docList):
        subDocList = docList[docidx:docidx+chunksize]
        docidx+=chunksize
        p = mp.Process(target=worker, args=(subDocList,))
        jobs.append(p)
        p.start()



