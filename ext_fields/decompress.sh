### decompress .tar.gz files for collected additional fields and mapping files for citations
# tar -zxf /home/w2wei/data/biocaddie/data/additional_fields/1.tar.gz
# tar -zxf /home/w2wei/data/biocaddie/data/additional_fields/1.tar.gz

for filename in /home/w2wei/data/biocaddie/data/additional_fields/*.tar.gz; do
	tar -zxf $filename
done