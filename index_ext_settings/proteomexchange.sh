curl -XDELETE '127.0.0.1:9200/proteomexchange_ext_nostd?pretty&pretty'
curl -XGET '127.0.0.1:9200/proteomexchange_ext_nostd?&pretty'
curl -XPUT '127.0.0.1:9200/proteomexchange_ext_nostd?pretty' -d'
{
  "settings" : {
    "number_of_shards" : 5,
    "number_of_replicas" : 1,
    "analysis" : {
      "char_filter" : {
          "new_line" : {
              "type" : "pattern_replace",
              "pattern": "\n\n *",
              "replacement": ". "
          }
      },        
      "filter" : {
        "asciifolding" : {
          "type" : "asciifolding",
          "preserve_original" : "true"
        },
        "english_possessive_stemmer" : {
          "type" : "stemmer",
          "language" : "possessive_english"
        },
        "nlm_stop" : {
          "type" : "stop",
          "stopwords" : [ "a", "about", "again", "all", "almost", "also", "although", "always", "among", "an", "and", "another", "any", "are", "as", "at", "be", "because", "been", "before", "being", "between", "both", "but", "by", "can", "could", "did", "do", "does", "done", "due", "during", "each", "either", "enough", "especially", "etc", "for", "found", "from", "further", "had", "has", "have", "having", "here", "how", "however", "i", "if", "in", "into", "is", "it", "its", "itself", "just", "kg", "km", "made", "mainly", "make", "may", "mg", "might", "ml", "mm", "most", "mostly", "must", "nearly", "neither", "no", "nor", "obtained", "of", "often", "on", "our", "overall", "perhaps", "pmid", "quite", "rather", "really", "regarding", "seem", "seen", "several", "should", "show", "showed", "shown", "shows", "significantly", "since", "so", "some", "such", "than", "that", "the", "their", "theirs", "them", "then", "there", "therefore", "these", "they", "this", "those", "through", "thus", "to", "upon", "use", "used", "using", "various", "very", "was", "we", "were", "what", "when", "which", "while", "with", "within", "without", "would" ]
        },
        "protwords" : {
          "type" : "keyword_marker",
          "keywords_path" : "analysis/mesh_and_entry_vocab.txt"
        },
        "light_english_stemmer" : {
          "type" : "stemmer",
          "language" : "light_english"
        }
      },
      "analyzer" : {
        "default" : {
          "char_filter": ["html_strip","new_line"],
          "filter" : [ "english_possessive_stemmer", "lowercase", "protwords", "asciifolding", "nlm_stop", "light_english_stemmer" ],
          "tokenizer" : "standard"
        },
        "tag_analyzer" : {
          "filter" : [ "lowercase", "asciifolding" ],
          "tokenizer" : "keyword"
        }
      }
    }
  }, 
  "mappings" : {
    "dataset" : {
      "properties" : {
        "dataItem" : {
          "properties" : {
            "dataTypes" : {
              "type" : "string",
              "index" : "not_analyzed"
            }
          }
        },
        "extension" : {
          "type" : "string",
          "analyzer" : "default"
        },             
        "dataRepository" : {
          "properties" : {
            "ID" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "abbreviation" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "homePage" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "name" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            }
          }
        },
        "dataset" : {
          "properties" : {
            "ID" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "dateReleased" : {
              "type" : "date",
              "ignore_malformed": true
            },
            "downloadURL" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "storedIn" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "title" : {
              "type" : "string",
              "analyzer" : "default"
            }
          }
        },
        "instrument" : {
          "properties" : {
            "name" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            }
          }
        },
        "keywords" : {
          "type" : "string",
          "analyzer" : "tag_analyzer"
        },
        "organism" : {
          "properties" : {
            "name" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            }
          }
        },
        "organization" : {
          "properties" : {
            "ID" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "abbreviation" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "homePage" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "name" : {
              "type" : "string",
              "analyzer" : "default"
            }
          }
        },
        "person" : {
          "properties" : {
            "name" : {
              "type" : "string",
              "analyzer" : "default"
            }
          }
        },
        "publication" : {
          "properties" : {
            "name" : {
              "type" : "string",
              "analyzer" : "default"
            }
          }
        },
        "std_description" : {
          "type" : "string",
          "analyzer" : "default"
        },
        "std_title" : {
          "type" : "string",
          "analyzer" : "default"
        },        
        "std_experimentType" : {
          "type" : "string",
          "analyzer" : "default"
        },
        "std_keywords" : {
          "type" : "string",
          "analyzer" : "tag_analyzer"
        },
        "std_organism" : {
          "type" : "string",
          "analyzer" : "tag_analyzer"
        }        
      }
    }
  }
}'