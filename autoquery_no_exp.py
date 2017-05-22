#!/usr/local/env python2.7
'''
    This script generates queries from provided questions, submits queries to pre-built indices, retrieves results and evaluates them. 
    input: a file contains raw questions.
    output: relevant doc ID list, relevant doc metadata, final queries

    Updated on Feb 10, 2017
    @author: Yupeng He
'''
import os,sys,json
from pubmed_query_analyzer import pubmed_query_analyzer
from Bio import Entrez
from constants import *
from nltk.corpus import stopwords
from elasticsearch import Elasticsearch, helpers

def read_questions(inputf):
    with open(inputf,'r') as fhandle:
        cur_qid = ""
        ques_info = {}
        ques_id = []
        questions = []
        for line in fhandle:
            line = line.rstrip()
            if len(line) == 0:
                continue
            elif(line[0] == ">"):
                cur_qid = line[1:]
                if ques_info.get(cur_qid) != None:
                    cur_qid
                ques_id.append(cur_qid)
                ques_info[cur_qid] = ""
                continue;
            else:
                ques_info[cur_qid] += line;
        for qid in ques_id:
            questions.append(ques_info[qid].lower())
    return((ques_id,questions))

def generate_json_query(pubmed_query,query_id,minimum_should_match = 1,size = 5000):
    if isinstance(minimum_should_match,int):
        minimum_should_match = [minimum_should_match]
    elif isinstance(minimum_should_match,list):
        pass
    else:
        exit("Invalid minimum_should_match value. It needs to an integer or a list.")
        return(None)

    json_query =  "[" + "\n"    
    for min_match in minimum_should_match:
        # Before query
        json_query += "{" + "\n"
        json_query += "\"query_id\":\"" + query_id + "\"," + "\n"
        json_query += "\"id\":\"" + query_id + "\"," + "\n"
        json_query += "\"query\":{" + "\n"
        json_query += "\"size\": \"" + str(size) + "\"," + "\n"
        json_query += "\"indices\":{\"indices\":[\"*_1106\"]}," + "\n"
        json_query += "\"query\":{" + "\n"
        json_query += "\"bool\":{" + "\n"
        json_query += "\"minimum_should_match\": " + str(min_match) + "," + "\n"
        json_query += "\"should\":[" + "\n"
    
        # First layer
        for first_cond in pubmed_query:
            json_query += "{" + "\n"
            json_query += "\"bool\":{" + "\n"
            json_query += "\"should\":[" + "\n"
            # Second layer
            for second_cond in first_cond:
                json_query += "{" + "\n"            
                json_query += "\"multi_match\":{" + "\n"
                json_query += "\"query\": \"" + second_cond + "\"," + "\n"
                json_query += "\"operator\": \"and\"," + "\n"
                json_query += "\"fields\":[\"_all\"]" + "\n"
                json_query += "}" + "\n"
                json_query += "}," + "\n"
            json_query = json_query[:-2] + "\n" ## Remove comma for the last element in the list
            json_query += "]" + "\n"
            json_query += "}" + "\n"
            json_query += "}," + "\n"

        # Rest of the json
        json_query = json_query[:-2] + "\n" ## Remove comma for the last element in the list
        json_query += "]" + "\n"
        json_query += "}" + "\n"
        json_query += "}" + "\n"
        json_query += "}" + "\n"
        json_query += "}," + "\n"
    json_query = json_query[:-2] + "\n" ## Remove comma for the last element in the list
    json_query += "]" + "\n"
    return(json_query)
    
if __name__ == "__main__":
    ## Get stopwords    
    predefined_stopwords = ["database","databases",
                        "datasets","dataset",
                        "data","related","relate","relation",
                        "type","types",
                        "studies","study",
                        "search","find","across",
                        "mention","mentions","mentioning"]
    stopwords_extended = stopwords.words("english") + predefined_stopwords
    stopwords_extended.remove("i") ## it may appear in phrase like "stage I"
    stopwords_extended.remove("a") ## it may appear in phrase like "type a"
    
    ## Input
    ## Input and output dirs
    if len(sys.argv) < 2:
        error_message = "Usage: python2.7 autoquery.py <question file>\n\n"
        sys.stderr.write(error_message)
        sys.exit(1)
    ## Read questions
    question_doc = sys.argv[1]
    ques_id, questions = read_questions(question_doc)

    ## Set up datamed_json_dir
    datamed_json_dir = os.path.join(data_base_dir,"datamed_json")
    ## Set up output dir
    es_res_dir = os.path.join(res_base_dir,"es_results")
    output_dir_in = sys.argv[2] ## e.g. raw_metadata_man_query
    out_dir = os.path.join(es_res_dir, output_dir_in)
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    ## Set up index type
    index_type_in = sys.argv[3]
    index_type = "*_"+index_type_in

    ## Get query expansion from pubmed
    json_queries = [] ## list of final queries in json format
    for ind in range(len(ques_id)):
        ## preprocess questions
        try:
            ques = " ".join([word for word in questions[ind].split(" ") if word not in stopwords_extended])
        except Exception as e:
            print e
            print ind

        internal_query = [set([word]) for word in ques.split(" ")]
        json_queries.append(json.loads(generate_json_query(internal_query,ques_id[ind],range(len(internal_query),0,-1))))            

    ## Search for datasets using elasticsearch
    ES_HOST = {"host": "127.0.0.1", "port": 9200}
    es = Elasticsearch(hosts=[ES_HOST],timeout=60)
    for ind in range(len(json_queries)):
        hit_id_list = []
        for ind_q in range(len(json_queries[ind])):
            q = json_queries[ind][ind_q]["query"]
            query = q.copy()
            del query["indices"]

            response = es.search(body=query,
                                 index = index_type,
                                 _source = False)
            hit_num = response['hits']['total']

            for doc in response['hits']['hits']:
                hit_id_list.append(doc['_id'])
            if(len(hit_id_list) > 5000):
                break
        
        ## Remove duplicated id
        hit_id_list_final = []
        seen = {}
        for doc_id in hit_id_list:
            if seen.get(doc_id):
                continue;
            else:
                seen[doc_id] = 1
                hit_id_list_final.append(doc_id)

        hit_id_list = hit_id_list_final

        ## Output query results        
        f = open(os.path.join(out_dir, ques_id[ind]+"_hit_id.txt"),'w')
        for doc_id in hit_id_list:
            f.write(doc_id+"\n")
        f.close()
        