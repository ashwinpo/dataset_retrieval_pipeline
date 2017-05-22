curl -XDELETE '127.0.0.1:9200/clinicaltrials_std?pretty&pretty'
curl -XGET '127.0.0.1:9200/clinicaltrials_std?&pretty'
curl -XPUT '127.0.0.1:9200/clinicaltrials_std?pretty' -d'
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
          "analyzer" : "tag_analyzer"
        },
        "std_gender" : {
          "type" : "string",
          "analyzer" : "tag_analyzer"
        },
        "std_treatment" : {
          "type" : "string",
          "analyzer" : "default"
        },
        "std_keywords" : {
          "type" : "string",
          "analyzer" : "tag_analyzer"
        },
        "std_disease" : {
          "type" : "string",
          "analyzer" : "tag_analyzer"
        },
        "extension" : {
          "type" : "string",
          "analyzer" : "default"
        },  
        "DataSet" : {
          "properties" : {
            "identifier" : {
              "type" : "string",
              "index" : "not_analyzed"
            }
          }
        },
        "Dataset" : {
          "properties" : {
            "briefTitle" : {
              "type" : "string",
              "analyzer" : "default"
            },
            "creator" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "depositionDate" : {
              "type" : "date",
              "ignore_malformed": true
            },
            "description" : {
              "type" : "string",
              "analyzer" : "default"
            },
            "has_expanded_access" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "is_fda_regulated" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "keyword" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "releaseDate" : {
              "type" : "date",
              "ignore_malformed": true
            },
            "title" : {
              "type" : "string",
              "analyzer" : "default"
            },
            "verificationDate" : {
              "type" : "date",
              "ignore_malformed": true
            }
          }
        },
        "Disease" : {
          "properties" : {
            "name" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            }
          }
        },
        "Grant" : {
          "properties" : {
            "funder" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            }
          }
        },
        "Publication" : {
          "properties" : {
            "citation" : {
              "type" : "string",
              "analyzer" : "default"
            }
          }
        },
        "Study" : {
          "properties" : {
            "homepage" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "identifier" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "location" : {
              "properties" : {
                "city" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "country" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "name" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "othercountries" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "zip" : {
                  "type" : "string",
                  "index" : "not_analyzed"
                }
              }
            },
            "phase" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "recruits" : {
              "properties" : {
                "criteria" : {
                  "type" : "string",
                  "analyzer" : "default"
                },
                "gender" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "maximum_age" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "minimum_age" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                }
              }
            },
            "status" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "studyType" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            }
          }
        },
        "StudyGroup" : {
          "properties" : {
            "description" : {
              "type" : "string",
              "analyzer" : "default"
            },
            "name" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "type" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            }
          }
        },
        "Treatment" : {
          "properties" : {
            "agent" : {
              "type" : "string",
              "analyzer" : "default"
            },
            "description" : {
              "type" : "string",
              "analyzer" : "default"
            },
            "title" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            }
          }
        },
        "clinical_study" : {
          "properties" : {
            "oversight_info" : {
              "properties" : {
                "authority" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "has_dmc" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                }
              }
            }
          }
        },
        "dataItem" : {
          "properties" : {
            "dataTypes" : {
              "type" : "string",
              "index" : "not_analyzed"
            }
          }
        },
        "internal" : {
          "properties" : {
            "link_text" : {
              "type" : "string",
              "analyzer" : "default"
            },
            "rank" : {
              "type" : "string",
              "index" : "not_analyzed"
            }
          }
        }
      }
    }
  }
}'