## copy 429 phenodisco datasets from the original dir to phenodisco_raw

import os, subprocess
from constants import *

source = os.path.join(data_base_dir, "archive/update_json_folder") #"/home/w2wei/data/biocaddie/data/archive/update_json_folder"
dest = os.path.join(data_base_dir, "phenodisco_raw") # "/home/w2wei/data/biocaddie/data/phenodisco_raw"
phen_dt_file = os.path.join(code_dir, "phenodisco_datasets")
phen_dts = filter(None, file(phen_dt_file).read().split("\n"))

for dt in phen_dts:
	subprocess.call(['cp',os.path.join(source,dt), dest])
