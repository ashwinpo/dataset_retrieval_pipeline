''' calculate the actual P@10 with partial relevant and without partial relevant 
    from Xiaoling, UT Houston
'''
import os
import sys
from constants import *

def get_annotated_result(annotated_file):
    """get annotated result in query:[docno list]"""
    f = file(annotated_file,'r')
    text = f.read()
    f.close()
    lines = text.split('\n')
    lines = [i for i in lines if i.strip()]
    result = {}
    for line in lines:
        words = line.split('\t')
        query = words[0]
        docno = words[2]
        relevant = words[3]
        if not query in result:
            result[query]={}
        result[query][docno]=relevant
    return result

def get_top_N_results(filename):
    """get top 10 result for each query for each file"""
    result = {}
    text = file(filename,'r').read()
    lines = text.split('\n')
    lines = [i for i in lines if i.strip()]
    c=0
    last_query=''
    for line in lines:
        words = line.split()
        query = words[0]
        docno = words[2]
        rank = int(words[3])
        if query not in result:
            result[query] = []
        if last_query!=query and last_query!='':
            c=0
        if c>=10:
            continue
        result[query].append(docno)
        last_query=query
        c = c+1
    return result

def get_ave_pN_plus_for_file(goldstand,predict):
    '''P(+partial)@10'''
    all_p = []
    for query in predict:
        num_relevant = 0
        for docno in predict[query]:
            try:
                if int(goldstand[query][docno])>0: #count partial as relevant
                    num_relevant +=1
            except Exception as e:
                print query, docno
                print e
        all_p.append(float(num_relevant)/len(predict[query]))
    average_p = sum(all_p)/len(all_p)
    return average_p

def get_ave_pN_minus_for_file(goldstand,predict):
    '''P(-partial)@10'''
    all_p = []
    for query in predict:
        num_relevant = 0
        for docno in predict[query]:
            try:
                if int(goldstand[query][docno])==2: #count partial as not relevant
                    num_relevant +=1
            except Exception as e:
                print query, docno
                print e                    
        all_p.append(float(num_relevant)/len(predict[query]))
    average_p = sum(all_p)/len(all_p)
    return average_p

if __name__=="__main__":
    # dataset_dir = 'new_submit_data'
    annotated_file = os.path.join(code_dir,'evaluation','biocaddie_qrels_4columns.txt')
    goldstand = get_annotated_result(annotated_file)
    res_file = sys.argv[1]
    filename = os.path.basename(res_file)
    predict= get_top_N_results(res_file)
    p10_plus = get_ave_pN_plus_for_file(goldstand,predict)
    p10_minus = get_ave_pN_minus_for_file(goldstand,predict)
    print '\t'.join([filename, 'P+@10',str(p10_plus),'P-@10',str(p10_minus)])


