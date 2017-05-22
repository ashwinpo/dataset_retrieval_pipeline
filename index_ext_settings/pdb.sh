curl -XDELETE '127.0.0.1:9200/pdb_ext_nostd?pretty&pretty'
curl -XGET '127.0.0.1:9200/pdb_ext_nostd?&pretty'
curl -XPUT '127.0.0.1:9200/pdb_ext_nostd?pretty' -d'
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
        "extension" : {
          "type" : "string",
          "analyzer" : "default"
        },          
        "citation" : {
          "properties" : {
            "DOI" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "PMID" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "author" : {
              "properties" : {
                "name" : {
                  "type" : "string",
                  "analyzer" : "default"
                }
              }
            },
            "firstPage" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "journal" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "journalISSN" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "lastPage" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "title" : {
              "type" : "string",
              "analyzer" : "default"
            },
            "year" : {
              "type" : "date",
              "ignore_malformed": true
            }
          }
        },
        "dataItem" : {
          "properties" : {
            "ID" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "dataTypes" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "depositionDate" : {
              "type" : "date",
              "ignore_malformed": true
            },
            "description" : {
              "type" : "string",
              "analyzer" : "default"
            },
            "keywords" : {
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
            }
          }
        },
        "dataResource" : {
          "type" : "object"
        },
        "gene" : {
          "properties" : {
            "name" : {
              "type" : "string",
              "analyzer" : "default"
            }
          }
        },
        "identifiers" : {
          "properties" : {
            "ID" : {
              "type" : "string",
              "index" : "not_analyzed"
            }
          }
        },
        "materialEntity" : {
          "properties" : {
            "formula" : {
              "type" : "string",
              "index" : "not_analyzed"
            },
            "name" : {
              "type" : "string",
              "analyzer" : "tag_analyzer"
            },
            "role" : {
              "type" : "string",
              "analyzer" : "default"
            },
            "type" : {
              "type" : "string",
              "analyzer" : "default"
            },
            "weight" : {
              "type" : "float"
            }
          }
        },
        "organism" : {
          "properties" : {
            "host" : {
              "properties" : {
                "genus" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "ncbiID" : {
                  "type" : "string",
                  "index" : "not_analyzed"
                },
                "scientificName" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "species" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "strain" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                }
              }
            },
            "source" : {
              "properties" : {
                "genus" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "ncbiID" : {
                  "type" : "string",
                  "index" : "not_analyzed"
                },
                "scientificName" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "species" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                },
                "strain" : {
                  "type" : "string",
                  "analyzer" : "tag_analyzer"
                }
              }
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
        "std_keywords" : {
          "type" : "string",
          "analyzer" : "tag_analyzer"
        },
        "std_experimentType" : {
          "type" : "string",
          "analyzer" : "default"
        },
        "std_organism" : {
          "type" : "string",
          "analyzer" : "tag_analyzer"
        }
      }
    }
  }    
}'