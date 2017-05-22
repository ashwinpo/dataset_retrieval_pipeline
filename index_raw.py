'''
    Follow https://qbox.io/blog/building-an-elasticsearch-index-with-python
    Build a ES index using provided data, using analyzers, stemmers, etc
    Index datasets according to the source databases

    Updated on May 20, 2017
    @author Wei Wei
'''
from elasticsearch import Elasticsearch, helpers
import json, cPickle, time, os, sys
from pprint import pprint
import string
printable = set(string.printable)
from constants import *


ES_HOST = {"host" : "127.0.0.1", "port" : 9200}
data_dir = sys.argv[1]
VERSION = sys.argv[2] # e.g. std_ext

## Load raw data
actions = []
t0=time.time()
count=0

print "Doc num: ", len(os.listdir(data_dir))

docList = os.listdir(data_dir)
t0=time.time()

## split all datasets into 5 parts, inject and index them iteratively
chunksize = len(docList)/5
chunk_idx = 1
start_idx = 0
while start_idx<len(docList):
    subList = docList[start_idx:start_idx+chunksize]
    start_idx+=chunksize
    print "Chunk index: ", chunk_idx
    chunk_idx+=1
    for fname in subList:
        if count%10000==0:
            print "doc num: ",count
        count+=1
        fullpath = os.path.join(data_dir, fname)
        text = file(fullpath).read()#.lower()
        raw_dat = json.loads(text)

        action = {}
        action['_id'] = raw_dat['DOCNO']
        action['_score'] = 0
        action['_type'] = 'dataset'
        action['_index'] = "_".join([raw_dat['REPOSITORY'].split("_")[0],VERSION])
        action['_source'] = raw_dat['METADATA']

        actions.append(action)

    t1=time.time()
    print "loading time: ", t1-t0
    print "doc num: ", count


    # create ES client, create index
    es = Elasticsearch(hosts = [ES_HOST], chunk_size=500, timeout=100000)

    indices=es.indices.get_alias().keys()
    print "init index num: ",len(indices)

    ## bulk index the data
    print("indexing...")
    t0=time.time()
    helpers.bulk(es, actions)
    t1=time.time()
    print "indexing time: ", t1-t0

    indices=es.indices.get_alias().keys()    
    print "final index num: ",len(indices)
    print

# sanity check
res = es.search(body={"query": {"match_all": {}}})
print("sanity check results:")
print len(res['hits']['hits'])
for hit in res['hits']['hits']:
    print hit['_id']
print