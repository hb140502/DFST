#!/bin/bash

. ./input_validation.sh
input_validation $@

my_dir="/vol/csedu-nobackup/project/hberendsen"
data_dir="$my_dir/data"
record_dir="$my_dir/record"
timestamp=$(date +"T%d-%m_%H-%M")

pratio_label=$(echo p$pratio | tr . -)
attack_id="${attack}_${model}_${dataset}_${pratio_label}"

# pyenv activate tf2.14
source /vol/csedu-nobackup/project/hberendsen/.pyenv/versions/tf2.14/bin/activate

gpu=$(python get_gpu.py)

if [[ ! $gpu =~ "RTX 2080 Ti" ]]; then
    echo "Unexpected GPU: ${gpu}"
    exit 1
fi

# Create json config based on attack settings
mkdir -p $record_dir/$attack_id
python create_config.py --dataset $dataset --network $model --epochs $n_epochs --poison_rate $pratio --save_dir $record_dir/$attack_id

python main.py --attack dfst --save_dir $record_dir/$attack_id --data_dir $data_dir

cd $record_dir    
tar -cf "${attack_id}_${timestamp}.tar" $attack_id
