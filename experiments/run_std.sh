## include standardized fields
## remove any fields that is over 32766 bytes from Phenodisco datasets
## index suffix _std

## Set up working directory
    WK_DIR="/home/w2wei/data/biocaddie"
    CODE_DIR=$WK_DIR/code
    DATA_DIR=$WK_DIR/data
    REST_DIR=$WK_DIR/results
    IDX_SFX="std"
    IDX_SETTING="index_std_settings"
    AUTO_ES_OUT="std_auto_ES"
    AUTO_PSD_ALL_OUT="std_auto_PSD_allwords" ## auto query -> ES results -> PSD allwords
    AUTO_PSD_KW_OUT="std_auto_PSD_keywords"
    MAN_ES_OUT="std_man_ES"

    cd $REST_DIR
    if [ "$(ls -A $REST_DIR/rerank)" ]; then
        echo "$REST_DIR/rerank exists"
    else
        mkdir rerank  
    fi      
    if [ "$(ls -A $REST_DIR/scores)" ]; then
        echo "$REST_DIR/scores exists"
    else
        mkdir scores        
    fi
    if [ "$(ls -A $REST_DIR/es_results)" ]; then
        echo "$REST_DIR/es_results exists"
    else
        mkdir es_results 
    fi


#1. Set up mapping schema
    cd $CODE_DIR
    python build_mapping_schema.py $IDX_SETTING $IDX_SFX
    python setup_build_indices.py $CODE_DIR/$IDX_SETTING
    sh $CODE_DIR/$IDX_SETTING/build_indices.sh

#2. Preprocess dataset metadata with fields longer than 32766 bytes, in particular, the Phenodisco datasets. The limit 32766 bytes is set by Elasticsearch
    ## make a copy of Phenodisco datasets from the original datasets
    if [ "$(ls -A $DATA_DIR/phenodisco_raw)" ]; then      
        echo "Phenodisco_raw exists"
    else
        python $CODE_DIR/get_phenodisco.py ## this script creates a dir phenodisco_raw under $DATA_DIR
        echo "Create Phenodisco_raw"
    fi
    ## remove very long fields, output dir:$DATA_DIR/phenodisco_strict
    python $CODE_DIR/remove_long_fields.py 
    ## move processed phenodisco metadata to datamed_json
    cp $DATA_DIR/phenodisco_strict/* $DATA_DIR/datamed_json/ ## datamed_json size 4464816

# 3. Index datasets
    ## build indices
    python $CODE_DIR/index_std.py $DATA_DIR/datamed_json $IDX_SFX

# 4. Evaluate ES autoquery performance 
    ## Extract keywords, expand keywords using NCBI e-utils, search ES indices with the expanded queries
    python autoquery.py T_questions.txt $AUTO_ES_OUT $IDX_SFX
    ## Format results for trec_eval and sample_eval
    python $CODE_DIR/evaluation/format_es_results.py $AUTO_ES_OUT T $AUTO_ES_OUT
    python $CODE_DIR/evaluation/call_sample_eval.py $REST_DIR/es_results/$AUTO_ES_OUT/T_es_results.trec > $REST_DIR/scores/$AUTO_ES_OUT
    # infAP = 0.2751
    # infNDCG = 0.4164
    # P+@10 = 0.6022

# 5. Evaluate ES non-exp-query performance 
    ## Extract keywords, search ES indices with the original keywords
    cd $CODE_DIR/
    python autoquery_no_exp.py T_questions.txt $MAN_ES_OUT $IDX_SFX
    ## Format results for trec_eval and sample_eval
    python $CODE_DIR/evaluation/format_es_results.py $MAN_ES_OUT T $MAN_ES_OUT
    python $CODE_DIR/evaluation/call_sample_eval.py $REST_DIR/es_results/$MAN_ES_OUT/T_es_results.trec > $REST_DIR/scores/$MAN_ES_OUT
    ## infAP=0.3058
    ## infNDCG=0.4015
    ## iP10=0.6711
