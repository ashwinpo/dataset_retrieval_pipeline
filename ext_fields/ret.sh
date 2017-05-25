## distribute the tasks to multiple machines
export WORK_PATH=/home/w2wei/data/biocaddie
data_dir=$WORK_PATH/data/datamed_json

gap=1
#python arrayexpress.py $data_dir sub1 $gap #&
#python arrayexpress.py $data_dir sub2 $gap &
#python arrayexpress.py $data_dir sub3 $gap &
#python arrayexpress.py $data_dir sub4 $gap &

#python gemma.py $data_dir sub1 $gap #&
#python gemma.py $data_dir sub2 $gap #&
#python gemma.py $data_dir sub3 $gap #&
#python gemma.py $data_dir sub4 $gap #&

#python geo.py $data_dir sub1 $gap &
#python geo.py $data_dir sub2 $gap &
#python geo.py $data_dir sub3 $gap &
#python geo.py $data_dir sub4 $gap &

python proteomexchange.py $data_dir sub1 $gap #&
#python proteomexchange.py $data_dir sub2 $gap &
#python proteomexchange.py $data_dir sub3 $gap &
#python proteomexchange.py $data_dir sub4 $gap &
