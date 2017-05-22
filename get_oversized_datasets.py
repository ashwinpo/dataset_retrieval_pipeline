'''
    Follow https://qbox.io/blog/building-an-elasticsearch-index-with-python
    Build a ES index using provided data, using analyzers, stemmers, etc
    Index datasets according to the source databases

    Updated on 11/09/2016
    @author Wei Wei
'''
from elasticsearch import Elasticsearch, helpers
import json, cPickle, time, os, sys
from pprint import pprint
import string
printable = set(string.printable)
from numbers import Number
from collections import Set, Mapping, deque
from constants import *


try: # Python 2
    zero_depth_bases = (basestring, Number, xrange, bytearray)
    iteritems = 'iteritems'
except NameError: # Python 3
    zero_depth_bases = (str, bytes, Number, range, bytearray)
    iteritems = 'items'

def getsize(obj_0):
    """Recursively iterate to sum size of object & members."""
    def inner(obj, _seen_ids = set()):
        obj_id = id(obj)
        if obj_id in _seen_ids:
            return 0
        _seen_ids.add(obj_id)
        size = sys.getsizeof(obj)
        if isinstance(obj, zero_depth_bases):
            pass # bypass remaining control flow and return
        elif isinstance(obj, (tuple, list, Set, deque)):
            size += sum(inner(i) for i in obj)
        elif isinstance(obj, Mapping) or hasattr(obj, iteritems):
            size += sum(inner(k) + inner(v) for k, v in getattr(obj, iteritems)())
        # Check for custom object instances - may subclass above too
        if hasattr(obj, '__dict__'):
            size += inner(vars(obj))
        if hasattr(obj, '__slots__'): # can have __slots__ with __dict__
            size += sum(inner(getattr(obj, s)) for s in obj.__slots__ if hasattr(obj, s))
        return size
    return inner(obj_0)

data_dir = os.path.join(data_base_dir,"datamed_json")
add_fields_dir = os.path.join(data_base_dir,"additional_fields")

## Load raw data
actions = []
t0=time.time()
count=0

print "Doc num: ", len(os.listdir(data_dir))

docList = os.listdir(data_dir)
t0=time.time()

fout = file("oversized_datasets","w")

for fname in docList:
    fullpath = os.path.join(data_dir, fname)
    text = file(fullpath).read()#.lower()
    raw_dat = json.loads(text)
    action = {}
    action['_id'] = raw_dat['DOCNO']
    action['_index'] = raw_dat['REPOSITORY']
    if action['_index'].startswith("phendisco"):
        action['_source'] = raw_dat['METADATA']
        size = getsize(action['_source'])
        if size>total_max_obj_size:
            count+=1
            out="%s:%s:%s"%(fname,action['_index'],size)
        print count
print "oversized dataset num: ", count

