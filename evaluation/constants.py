import os
from Bio import Entrez

## code dir
code_dir = "/home/w2wei/data/biocaddie/code"

## data dir
data_base_dir = "/home/w2wei/data/biocaddie/data"

## result dir
res_base_dir = "/home/w2wei/data/biocaddie/results"

## emails
Entrez.email = "armyofucsdgrads@ucsd.edu" ## set your email address

## maximum object size allowed in Elasticsearch
max_size = 32766

