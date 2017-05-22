import sys

infile=sys.argv[1]
fin=file(infile)
text=fin.read().split("\n")
new=[]
for line in text:
	if line.startswith("T"):
		new.append(line[1:])
outfile=sys.argv[2]
fout=file(outfile,"w")
fout.write("\n".join(new))