## This version is for experiment ext_std_strict
import os, subprocess, json, sys
from constants import *

if __name__=="__main__":
    datamed_json_dir = os.path.join(data_base_dir, "phenodisco_raw") 
    outdir = os.path.join(data_base_dir, "phenodisco_strict") 
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    phendisco_dts = os.listdir(datamed_json_dir)
    print "phendisco dataset num: ", len(phendisco_dts)

    for doc in phendisco_dts:
        text = file(os.path.join(datamed_json_dir,doc)).read()
        raw_dat = json.loads(text)
        try:
            del raw_dat['METADATA']["phenCUI"]
        except:
            pass
        try:
            del raw_dat['METADATA']["phenID"]
        except:
            pass

        try:
            phenmap = raw_dat['METADATA']["phenMap"]
            if sys.getsizeof(phenmap)>max_size:
                del raw_dat['METADATA']["phenMap"]
        except Exception as e:
            print doc
            print e
        try:
            phen = raw_dat['METADATA']["phen"]
            if sys.getsizeof(phen)>max_size:
                del raw_dat['METADATA']["phen"]
        except Exception as e:
            print doc
            print e
        
        for key in raw_dat['METADATA'].keys():
            obj = raw_dat['METADATA'][key]
            if sys.getsizeof(obj)>max_size:
                print "field: ", key
                del raw_dat['METADATA'][key]

        outstr = json.dumps(raw_dat)
        fout = file(os.path.join(outdir,doc), 'w')
        fout.write(outstr)


