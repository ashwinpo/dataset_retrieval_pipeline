'''
    Formulate Elasticsearch retrieved hit doc ids to a 6-column TREC format 
    Updated on 05/06/2017
    @author: Wei Wei
'''
import os, sys
import numpy as np
import pandas as pd
cwd =os.path.dirname(os.path.abspath(__file__))
from constants import *

if __name__=="__main__":
    if len(sys.argv) < 4:
        error_message = "Usage: python format_es_results.py <ES result dir> <dataset type> <run id>. Dataset type is either E for E1-E30, or T for T1-T15. Run id is self-defined, e.g. raw_meta. \n\n"
        sys.stderr.write(error_message)
        sys.exit(1)
    ## load data
    in_dir = sys.argv[1]
    es_res_dir = os.path.join(res_base_dir, "es_results", in_dir) 
    group = sys.argv[2] ## E for E1-E30, T for T1-T15
    docs = os.listdir(es_res_dir)
    hit_docs = filter(lambda s:("_hit_id" in s) & s.startswith(group), docs)

    run_id = sys.argv[3] ## run_id, e.g. raw_meta
    result_df = []
    index = 1
    for doc in hit_docs:
        hits = file(os.path.join(es_res_dir,doc)).read().split("\n")
        hits = filter(None, hits)

        qid = doc.split("_")[0][1:]
        ite = 0
        docno = hits
        rank = np.array(range(1,1+len(hits)))
        sim = 1.0/(rank+1)

        data = {"qid":pd.Series([qid]*len(hits), index=range(index, index+len(hits))),
                "iter":pd.Series([ite]*len(hits), index=range(index, index+len(hits))),
                "docno":pd.Series(docno, index=range(index, index+len(hits))),
                "rank":pd.Series(rank, index=range(index, index+len(hits))),
                "sim":pd.Series(sim, index=range(index, index+len(hits))),
                "run_id":pd.Series([run_id]*len(hits), index=range(index, index+len(hits)))}
        data_df = pd.DataFrame(data, columns=['qid', 'iter', 'docno', 'rank', 'sim', 'run_id'])
        result_df.append(data_df)
        index+=len(hits)

    result_df = pd.concat(result_df)
    # print result_df
    outfile = "%s_es_results.trec"%group
    result_df.to_csv(os.path.join(es_res_dir, outfile), header=None, index=None, sep=' ', mode='w')
    ## TREC format
    #    qid  iter   docno  rank       sim run_id
    # 0   12     0   24726     0  1.000000   test
    # 1   12     0  356595     1  0.500000   test
    # 2   12     0  131935     2  0.333333   test
    # 3   12     0    5645     3  0.250000   test
    # 4   12     0  393057     4  0.200000   test
