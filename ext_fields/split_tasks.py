import os,json,time,cPickle
from pprint import pprint
cwd =os.path.dirname(os.path.abspath(__file__))
from constants import *

def set_repo_dsID_dict(data_dir, out_file):
    repoList = ["arrayexpress", "bioproject", "clinicaltrials", "dryad", "gemma","geo", "mpd", "neuromorpho", "nursadatasets", "pdb", "proteomexchange"]
    repoDict = {repo:[] for repo in repoList}
    docList = os.listdir(data_dir)
    count=0
    for doc in docList:
        count+=1
        if count%10000==0:
            print 'doc count: ', count
        dat = json.loads(file(os.path.join(data_dir,doc)).read())
        repo = dat['REPOSITORY'].split("_")[0]
        if repoDict.get(repo, None)!=None:
            repoDict[repo].append(doc)
    cPickle.dump(repoDict, file(out_file,"w"))

def load_all_docs(all_docid_dict_file,enabled_repos):
    repo_dsID_dict = cPickle.load(file(all_docid_dict_file))
    fourrepos = {}
    for repo in enabled_repos:
        fourrepos[repo]=repo_dsID_dict[repo]
    return fourrepos

def find_unchecked(rawDict, checked_doc_list):
    new_dict = {}
    for repo, docList in rawDict.iteritems():
        unchecked = set(docList)-set(checked_doc_list)
        new_dict[repo] = list(unchecked)
    return new_dict

def split_tasks(inDict, outDir):
    sub1, sub2, sub3, sub4 = {},{},{},{}
    for repo, docList in inDict.iteritems():
        size = len(docList)/4
        sub1[repo] = docList[:size]
        sub2[repo] = docList[size:size*2]
        sub3[repo] = docList[size*2:size*3]
        sub4[repo] = docList[size*3:]
    cPickle.dump(sub1, file(os.path.join(outDir,"sub1.pkl"),"w"))
    cPickle.dump(sub2, file(os.path.join(outDir,"sub2.pkl"),"w"))
    cPickle.dump(sub3, file(os.path.join(outDir,"sub3.pkl"),"w"))
    cPickle.dump(sub4, file(os.path.join(outDir,"sub4.pkl"),"w"))

if __name__=="__main__":
    data_dir = os.path.join(data_base_dir, "datamed_json")

    repo_dsID_dict_file = os.path.join(code_dir, "ext_fields/repo_dsID_dict.pkl") #"./repo_dsID_dict.pkl" ## all datasets from the 11 repos

    enabled_repos = ["arrayexpress","gemma","geo","proteomexchange"]
    
    sub_repo_dsID_dict_dir = "./sub_repo_dsID_dict" ## for each vm
    if not os.path.exists(sub_repo_dsID_dict_dir):
        os.makedirs(sub_repo_dsID_dict_dir)

    ## load the dict for geo, arrayexpress, gemma, proteomexchange datasets
    if not os.path.exists(repo_dsID_dict_file):
        set_repo_dsID_dict(data_dir, repo_dsID_dict_file) ## output repo_dsID_dict.pkl, format: {repo:[dataset id list]}
    repo_dsID_dict = load_all_docs(repo_dsID_dict_file, enabled_repos)
    # for k, v in repo_dsID_dict.iteritems():
    #     print k, len(v)
    
    ## load a list of check docs
    add_text_dir = os.path.join(data_base_dir, "additional_fields")
    checked_dsID_list = os.listdir(add_text_dir)

    ## get unchecked datasets
    unchecked_dsID_dict = find_unchecked(repo_dsID_dict, checked_dsID_list)
    for k, v in unchecked_dsID_dict.iteritems():
        print k, len(v)

    ## split dataset ids
    split_tasks(unchecked_dsID_dict, sub_repo_dsID_dict_dir)





