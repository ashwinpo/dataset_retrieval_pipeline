## extend metadata with additional fields
## include standardized fields
## remove any fields that is over 32766 bytes from Phenodisco datasets
## index suffix _std_ext

## Set up working directory
    WK_DIR="/your/work/path"
    CODE_DIR=$WK_DIR/code
    DATA_DIR=$WK_DIR/data
    REST_DIR=$WK_DIR/results
    IDX_SFX="std_ext_val"
    IDX_SETTING="index_std_ext_settings"
    
    AUTO_ES_OUT="ext_std_strict_auto_val_ES"
    AUTO_ES_OUT_NDCG="ext_std_strict_auto_val_ES_NDCG"
    AUTO_ES_OUT_PREC="ext_std_strict_auto_val_ES_PREC"
    
    AUTO_PSD_ALL_OUT="ext_std_strict_auto_PSD_allwords" ## auto query -> ES results -> PSD allwords
    AUTO_PSD_ALL_OUT_NDCG="ext_std_strict_auto_PSD_allwords_NDCG" ## auto query -> ES results -> PSD allwords
    AUTO_PSD_ALL_OUT_PREC="ext_std_strict_auto_PSD_allwords_PREC" ## auto query -> ES results -> PSD allwords

    AUTO_PSD_KW_OUT="ext_std_strict_auto_PSD_keywords"
    AUTO_PSD_KW_OUT_NDCG="ext_std_strict_auto_PSD_keywords_NDCG"
    AUTO_PSD_KW_OUT_PREC="ext_std_strict_auto_PSD_keywords_PREC"
    
    AUTO_PSD_GOOG_OUT="ext_std_strict_auto_PSD_google"
    AUTO_PSD_GOOG_OUT_NDCG="ext_std_strict_auto_PSD_google_NDCG"
    AUTO_PSD_GOOG_OUT_PREC="ext_std_strict_auto_PSD_google_PREC"

    MAN_ES_OUT="ext_std_strict_man_val_ES"
    MAN_ES_OUT_NDCG="ext_std_strict_man_val_ES_NDCG"
    MAN_ES_OUT_PREC="ext_std_strict_man_val_ES_PREC"

    AUTO_VOTE_OUT="ext_std_strict_auto_vote"
    AUTO_VOTE_OUT_NDCG="ext_std_strict_auto_vote_NDCG"
    AUTO_VOTE_OUT_PREC="ext_std_strict_auto_vote_PREC"

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
    python $CODE_DIR/get_phenodisco.py ## this script creates a dir phenodisco_raw under $DATA_DIR
    ## remove very long fields, output dir:$DATA_DIR/phenodisco_strict
    python $CODE_DIR/remove_long_fields.py 
    ## move processed phenodisco metadata to datamed_json
    cp $DATA_DIR/phenodisco_strict/* $DATA_DIR/datamed_json/ ## datamed_json size 4464816

# 3. Index datasets
    ## build indices
    python $CODE_DIR/index_std_ext.py $DATA_DIR/datamed_json $IDX_SFX

# 4. Evaluate ES autoquery performance 
    ## Extract keywords, expand keywords using NCBI e-utils, search ES indices with the expanded queries
    cd $CODE_DIR
    python autoquery.py T_questions.txt $AUTO_ES_OUT $IDX_SFX
    ## Format results for trec_eval and sample_eval
    python $CODE_DIR/evaluation/format_es_results.py $AUTO_ES_OUT T $AUTO_ES_OUT
    python $CODE_DIR/evaluation/call_sample_eval.py $REST_DIR/es_results/$AUTO_ES_OUT/T_es_results.trec > $REST_DIR/scores/$AUTO_ES_OUT
    python $CODE_DIR/evaluation/call_treceval.py $REST_DIR/es_results/$AUTO_ES_OUT/T_es_results.trec > $REST_DIR/scores/$AUTO_ES_OUT_NDCG    
    python $CODE_DIR/evaluation/calculate_actual_p10.py $REST_DIR/es_results/$AUTO_ES_OUT/T_es_results.trec > $REST_DIR/scores/$AUTO_ES_OUT_PREC    
    # infAP=0.2446
    # infNDCG=0.4333
    # NDCG@10=0.4228
    # P+@10=0.5200
    # P-@10=0.2733

# 5. Evaluate ES non-exp-query performance 
    ## Extract keywords, search ES indices with the original keywords
    python autoquery_no_exp.py T_questions.txt $MAN_ES_OUT $IDX_SFX
    ## Format results for trec_eval and sample_eval
    python $CODE_DIR/evaluation/format_es_results.py $MAN_ES_OUT T $MAN_ES_OUT
    python $CODE_DIR/evaluation/call_sample_eval.py $REST_DIR/es_results/$MAN_ES_OUT/T_es_results.trec > $REST_DIR/scores/$MAN_ES_OUT
    python $CODE_DIR/evaluation/call_treceval.py $REST_DIR/es_results/$MAN_ES_OUT/T_es_results.trec > $REST_DIR/scores/$MAN_ES_OUT_NDCG
    python $CODE_DIR/evaluation/calculate_actual_p10.py $REST_DIR/es_results/$MAN_ES_OUT/T_es_results.trec > $REST_DIR/scores/$MAN_ES_OUT_PREC    
    ## infAP=0.2845
    ## infNDCG=0.3961
    ## NDCG@10=0.4771
    ## P+@10=0.6333
    ## P-@10=0.2933
    
# 6. Rerank: PSD-allwords
    # reformat metadata for PSD models
    PSD_DATA_DIR=$DATA_DIR/datamed_json4rerank
    if [ "$(ls -A $PSD_DATA_DIR)" ]; then
        python $CODE_DIR/format_PSD_model_data.py phen
        cp $DATA_DIR/phenodisco_strict/* $DATA_DIR/datamed_json4rerank        
        echo "Update Phenodisco dataset metadata only"
    else
        echo "Create reformatted metatadata for all datasets"
        python $CODE_DIR/format_PSD_model_data.py all  
    fi
    ## edit PSD parameters
    python $CODE_DIR/edit_java_constants.py $CODE_DIR/all_questions.txt $REST_DIR/es_results/$AUTO_ES_OUT/ $REST_DIR/rerank/$AUTO_PSD_ALL_OUT.txt
    ## OR manually edit Constants.java
    # compile
    cd $CODE_DIR/rerank/PSD/
    javac *.java
    ## run
    java MainEntry

    ## Evaluate PSD-allwords performance
    ## format outcomes
    cd $CODE_DIR
    python $CODE_DIR/evaluation/format_psd_results.py $REST_DIR/rerank/$AUTO_PSD_ALL_OUT.txt $REST_DIR/rerank/$AUTO_PSD_ALL_OUT.trec
    python $CODE_DIR/evaluation/call_sample_eval.py $REST_DIR/rerank/$AUTO_PSD_ALL_OUT.trec > $REST_DIR/scores/$AUTO_PSD_ALL_OUT
    python $CODE_DIR/evaluation/call_treceval.py $REST_DIR/rerank/$AUTO_PSD_ALL_OUT.trec > $REST_DIR/scores/$AUTO_PSD_ALL_OUT_NDCG
    python $CODE_DIR/evaluation/calculate_actual_p10.py $REST_DIR/rerank/$AUTO_PSD_ALL_OUT.trec > $REST_DIR/scores/$AUTO_PSD_ALL_OUT_PREC    
    # infAP = 0.2792
    # infNDCG = 0.4980
    # NDCG@10 = 0.6152
    # P+@10 = 0.7600
    # P-@10 = 0.3267

# 7. Rerank: PSD-keywords
    ## edit PSD parameters
    python $CODE_DIR/edit_java_constants.py $CODE_DIR/kw_questions.txt $REST_DIR/es_results/$AUTO_ES_OUT/ $REST_DIR/rerank/$AUTO_PSD_KW_OUT.txt
    ## compile and run
    cd $CODE_DIR/rerank/PSD/
    javac *.java
    java MainEntry
    # ## format outcomes
    cd $CODE_DIR
    python $CODE_DIR/evaluation/format_psd_results.py $REST_DIR/rerank/$AUTO_PSD_KW_OUT.txt $REST_DIR/rerank/$AUTO_PSD_KW_OUT.trec
    python $CODE_DIR/evaluation/call_sample_eval.py $REST_DIR/rerank/$AUTO_PSD_KW_OUT.trec > $REST_DIR/scores/$AUTO_PSD_KW_OUT
    python $CODE_DIR/evaluation/call_treceval.py $REST_DIR/rerank/$AUTO_PSD_KW_OUT.trec > $REST_DIR/scores/$AUTO_PSD_KW_OUT_NDCG
    python $CODE_DIR/evaluation/calculate_actual_p10.py $REST_DIR/rerank/$AUTO_PSD_KW_OUT.trec > $REST_DIR/scores/$AUTO_PSD_KW_OUT_PREC    
    # infAP = 0.2391
    # infNDCG = 0.4490
    # NDCG@10 = 0.4088
    # P+@10 = 0.5200
    # P-@10 = 0.1667

# 8. Rerank: Distribution shift
    ## edit PSD parameters
    python $CODE_DIR/edit_java_constants.py $CODE_DIR/google_questions.txt $REST_DIR/es_results/$AUTO_ES_OUT/ $REST_DIR/rerank/$AUTO_PSD_GOOG_OUT.txt
    ## compile and run
    cd $CODE_DIR/rerank/PSD/
    javac *.java
    java MainEntry
    ## format outcomes
    cd $CODE_DIR
    python $CODE_DIR/evaluation/format_psd_results.py $REST_DIR/rerank/$AUTO_PSD_GOOG_OUT.txt $REST_DIR/rerank/$AUTO_PSD_GOOG_OUT.trec
    python $CODE_DIR/evaluation/call_sample_eval.py $REST_DIR/rerank/$AUTO_PSD_GOOG_OUT.trec > $REST_DIR/scores/$AUTO_PSD_GOOG_OUT
    python $CODE_DIR/evaluation/call_treceval.py $REST_DIR/rerank/$AUTO_PSD_GOOG_OUT.trec > $REST_DIR/scores/$AUTO_PSD_GOOG_OUT_NDCG
    python $CODE_DIR/evaluation/calculate_actual_p10.py $REST_DIR/rerank/$AUTO_PSD_GOOG_OUT.trec > $REST_DIR/scores/$AUTO_PSD_GOOG_OUT_PREC            
    # infAP = 0.3309
    # infNDCG = 0.4783
    # NDCG@10 = 0.6504
    # P+@10 = 0.7467
    # P-@10 = 0.36
    
# 9. Rerank: Ensemble
    cd $CODE_DIR/rerank/vote
    perl merge_ranking_avg.pl $REST_DIR/rerank/$AUTO_PSD_KW_OUT.trec $REST_DIR/rerank/$AUTO_PSD_ALL_OUT.trec > $REST_DIR/rerank/$AUTO_VOTE_OUT.trec
    cd $CODE_DIR
    python $CODE_DIR/evaluation/call_sample_eval.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT
    python $CODE_DIR/evaluation/call_treceval.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT_NDCG
    python $CODE_DIR/evaluation/calculate_actual_p10.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT_PREC 
    # infAP = 0.2801
    # infNDCG = 0.4847
    # NDCG@10 = 0.5398
    # P+@10 = 0.6800
    # P-@10 = 0.2400

    # cd $CODE_DIR/rerank/vote
    # perl merge_ranking_avg.pl $REST_DIR/rerank/$AUTO_PSD_ALL_OUT.trec $REST_DIR/rerank/$AUTO_PSD_GOOG_OUT.trec > $REST_DIR/rerank/$AUTO_VOTE_OUT.trec
    # cd $CODE_DIR
    # python $CODE_DIR/evaluation/call_sample_eval.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT
    # python $CODE_DIR/evaluation/call_treceval.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT_NDCG
    # python $CODE_DIR/evaluation/calculate_actual_p10.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT_PREC    
    # infAP = 0.3216
    # infNDCG = 0.4735
    # NDCG@10 = 0.6439
    # P+@10 = 0.7733
    # P-@10 = 0.3333

    # cd $CODE_DIR/rerank/vote
    # perl merge_ranking_avg.pl $REST_DIR/rerank/$AUTO_PSD_KW_OUT.trec $REST_DIR/rerank/$AUTO_PSD_GOOG_OUT.trec > $REST_DIR/rerank/$AUTO_VOTE_OUT.trec
    # cd $CODE_DIR
    # python $CODE_DIR/evaluation/call_sample_eval.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT
    # python $CODE_DIR/evaluation/call_treceval.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT_NDCG
    # python $CODE_DIR/evaluation/calculate_actual_p10.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT_PREC    
    # infAP = 0.3120
    # infNDCG = 0.4442
    # NDCG@10 = 0.5649
    # P+@10 = 0.6800
    # P-@10 = 0.2800

    # cd $CODE_DIR/rerank/vote
    # perl merge_ranking_avg.pl $REST_DIR/rerank/$AUTO_PSD_KW_OUT.trec $REST_DIR/rerank/$AUTO_PSD_ALL_OUT.trec $REST_DIR/rerank/$AUTO_PSD_GOOG_OUT.trec> $REST_DIR/rerank/$AUTO_VOTE_OUT.trec
    # cd $CODE_DIR
    # python $CODE_DIR/evaluation/call_sample_eval.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT
    # python $CODE_DIR/evaluation/call_treceval.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT_NDCG
    # python $CODE_DIR/evaluation/calculate_actual_p10.py $REST_DIR/rerank/$AUTO_VOTE_OUT.trec > $REST_DIR/scores/$AUTO_VOTE_OUT_PREC 
    # # infAP = 0.2801
    # # infNDCG = 0.4847
    # # NDCG@10 = 0.5398
    # # P+@10 = 0.6800
    # # P-@10 = 0.2400