## This version is for experiment ext_std_strict
import os, subprocess, json, sys

max_size=32766
if __name__=="__main__":
    datamed_json_dir = "/home/w2wei/data/biocaddie/data/phenodisco_raw"     
    outdir = "/home/w2wei/data/biocaddie/data/phenodisco_strict"
    phendisco_dts = os.listdir(datamed_json_dir)
    print "phendisco_dts num: ", len(phendisco_dts)

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
        print doc
        print sys.getsizeof(outstr)
        fout = file(os.path.join(outdir,doc), 'w')
        fout.write(outstr)


