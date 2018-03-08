#!/bin/bash

. ./path.sh || exit 1
. ./cmd.sh || exit 1

nj=1       # number of parallel jobs - 1 is perfect for such a small data set

##################################################################
################# CONFIGURATION PARAMETERS #######################
##################################################################
markings=(wb lr l r)
alphas=(0.05 0.2 0.5 1 1.5)
language=sme
gender=F
speaker="${language}_$gender"
lm_corpus=wikipedia_small.txt

# SOURCE FOLDERS BASED ON CONF PARAMETERS
audio_data=/scratch/elec/puhe/p/sami/audio_data/$speaker
lm_src=/scratch/elec/puhe/p/sami/lmdata/$language/$lm_corpus
lm_dir=/scratch/work/jpleino1/kaldi-trunk/egs/${speaker}/data/local/lm
lang_dir=/scratch/elec/puhe/p/sami/langdata/kaldi/$language

if [ $gender = "F" ]
then 
	name_length=12
else
	name_length=11
fi

# Safety mechanism (possible running this script with modified arguments)
. utils/parse_options.sh || exit 1
[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; }


mkdir data exp mfcc data/train data/eval data/dev data/local data/lang data/local/lm

# Getting the phonemes
mkdir data/dict data/lang data/lang/local 
cp $lang_dir/dict/* data/dict

echo
echo "===== PREPARING ACOUSTIC DATA ====="
echo

local/prepare_from_iwclul2016.sh $lm_src $audio_data $lm_dir $name_length

# Making spk2utt files
utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
utils/utt2spk_to_spk2utt.pl data/eval/utt2spk > data/eval/spk2utt
utils/utt2spk_to_spk2utt.pl data/dev/utt2spk > data/dev/spk2utt

echo
echo "===== FEATURES EXTRACTION ====="
echo

# Making feats.scp files
mfccdir=mfcc
# Uncomment and modify arguments in scripts below if you have any problems with data sorting
utils/validate_data_dir.sh data/train     # script for checking prepared data - here: for data/train directory
utils/fix_data_dir.sh data/train          # tool for data proper sorting if needed - here: for data/train directory
utils/validate_data_dir.sh data/eval     # script for checking prepared data - here: for data/train directory
utils/fix_data_dir.sh data/eval          # tool for data proper sorting if needed - here: for data/train directory
utils/validate_data_dir.sh data/dev     # script for checking prepared data - here: for data/train directory
utils/fix_data_dir.sh data/dev          # tool for data proper sorting if needed - here: for data/train directory
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/train exp/make_mfcc/train $mfccdir
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/eval exp/make_mfcc/eval $mfccdir
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/dev exp/make_mfcc/dev $mfccdir

# Making cmvn.scp files
steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir
steps/compute_cmvn_stats.sh data/eval exp/make_mfcc/eval $mfccdir
steps/compute_cmvn_stats.sh data/dev exp/make_mfcc/dev $mfccdir

echo
echo "===== LANGUAGE MODEL CREATION ====="
echo "===== MAKING lm.arpa ====="
echo


# Building and pruning a word model
local/run_SRILM.sh $lm_dir
local/lexicon.py $lm_dir/corpus.txt
mv lexicon.txt data/dict


echo
echo "===== PREPARING LANGUAGE DATA AND MAKING G.fst ====="
echo

extra=3

utils/prepare_lang.sh data/dict "<UNK>" data/lang/local data/lang

#utils/format_lm_sri.sh data/lang $lm_dir/kaldi_srilm-prune=5e10.4bo data/lang_test
#mv data/lang_test/G.fst data/lang
rm -rf data/lang_test

echo
echo "===== MONO TRAINING ====="
echo

steps/train_mono.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono  || exit 1

echo
echo "===== MONO DECODING ====="
echo

utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph || exit 1
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/mono/graph data/eval exp/mono/decode

echo
echo "===== MONO ALIGNMENT ====="
echo

steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono exp/mono_ali || exit 1

echo
echo "===== TRI1 (first triphone pass) TRAINING ====="
echo

steps/train_deltas.sh --cmd "$train_cmd" 2000 11000 data/train data/lang exp/mono_ali exp/tri1 || exit 1

echo
echo "===== TRI1 (first triphone pass) DECODING ====="
echo

utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph || exit 1
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri1/graph data/eval exp/tri1/decode

echo
echo "===== TRI1 ALIGNMENT ====="
echo

steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/tri1 exp/tri1_ali || exit 1

echo
echo "===== TRI2b (LDA+MLLT) TRAINING ====="
echo

steps/train_lda_mllt.sh --cmd "$train_cmd" --splice-opts "--left-context=3 --right-context=3" 2500 15000 data/train data/lang exp/tri1_ali exp/tri2b

echo
echo "===== TRI2b ALIGNMENT ====="
echo

steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/tri2b exp/tri2b_ali || exit 1

echo
echo "===== TRI3b (LDA+MLLT+SAT) TRAINING ====="
echo

steps/train_sat.sh --cmd "$train_cmd" 2500 15000 data/train data/lang exp/tri2b_ali exp/tri3b

echo
echo "===== TRI3b (LDA+MLLT+SAT) DECODING  ====="
echo

utils/mkgraph.sh data/lang exp/tri3b exp/tri3b/graph || exit 1
steps/decode_fmllr.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri3b/graph data/eval exp/tri3b/decode

###########################
### NNET3 parameters ######
###########################
test_sets="dev"
nnet_lm_dir=/scratch/work/jpleino1/kaldi-trunk/egs/${speaker}/exp/tri3b/graph_ones_wb_a0_2_D0_0002
tdnn_affix=1a
max_param_change=2.0
num_epochs=3
train_samples_per_iter=400000
init_lrate=0.0015
final_lrate=0.00015
graph_affix=""
echo
echo "===== TDNN TRAINING ====="
echo

local/nnet3/run_tdnn.sh --stage 0 $test_sets $nnet_lm_dir $tdnn_affix $max_param_change $num_epochs $train_samples_per_iter $init_lrate $final_lrate
utils/mkgraph.sh $dir exp/tri3b exp/tri3b/graph_${comtype}_${marking}_a${str_alp}_D${str_D}

tdnn_affix=1a
local/nnet3/run_tdnn.sh --stage 14 $test_sets $nnet_lm_dir $tdnn_affix $max_param_change $num_epochs $train_samples_per_iter $init_lrate $final_lrate

tdnn_affix=1a_2layers
local/nnet3/run_tdnn.sh --stage 14 $test_sets $nnet_lm_dir $tdnn_affix $max_param_change $num_epochs $train_samples_per_iter $init_lrate $final_lrate

tdnn_affix=1a_3layers
local/nnet3/run_tdnn.sh --stage 14 $test_sets $nnet_lm_dir $tdnn_affix $max_param_change $num_epochs $train_samples_per_iter $init_lrate $final_lrate

tdnn_affix=1a_4layers
local/nnet3/run_tdnn.sh --stage 14 $test_sets $nnet_lm_dir $tdnn_affix $max_param_change $num_epochs $train_samples_per_iter $init_lrate $final_lrate

tdnn_affix=1a_lr_314
local/nnet3/run_tdnn.sh --stage 14 $test_sets $nnet_lm_dir $tdnn_affix $max_param_change $num_epochs $train_samples_per_iter $init_lrate $final_lrate

tdnn_affix=1a_mpc_3
local/nnet3/run_tdnn.sh --stage 14 $test_sets $nnet_lm_dir $tdnn_affix $max_param_change $num_epochs $train_samples_per_iter $init_lrate $final_lrate

tdnn_affix=1a_ne_5
local/nnet3/run_tdnn.sh --stage 14 $test_sets $nnet_lm_dir $tdnn_affix $max_param_change $num_epochs $train_samples_per_iter $init_lrate $final_lrate

echo
echo "===== run.sh script is finished ====="
echo
