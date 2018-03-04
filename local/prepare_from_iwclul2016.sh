#!/bin/bash

if [ $# != 4 ]; then

  echo "You're doing this wrong"
  exit 1;
fi

wiki=$1
src_dir=$2
lm_targerdir=$3
name_length=$4

train_cp=train_cp.trn
eval_cp=eval_cp.trn
dev_cp=dev_cp.trn
pre_corpus=pre_corpus.txt

# Create language model corpus
cp $wiki $pre_corpus
sed -i 's/\.//g' $pre_corpus
sed -i "s/'//g" $pre_corpus

cp $src_dir/train_9000.trn $train_cp
cp $src_dir/eval.trn $eval_cp
cp $src_dir/devel200.trn $dev_cp

sed -i 's/\.//g' $train_cp
sed -i "s/'//g" $train_cp

sed -i 's/\.//g' $eval_cp
sed -i "s/'//g" $eval_cp

sed -i 's/\.//g' $dev_cp
sed -i "s/'//g" $dev_cp

local/trn2text.py $train_cp
cut -c$name_length- text > train_corpus.txt 
mv text data/train

local/trn2text.py $eval_cp
mv text data/eval

local/trn2text.py $dev_cp
cut -c$name_length- text > dev_corpus.txt
mv text data/dev
mv dev_corpus.txt data/dev

cat $pre_corpus train_corpus.txt > corpus.txt
mv corpus.txt data/local/lm

rm $train_cp
rm $eval_cp
rm $pre_corpus
rm $dev_cp

rm train_corpus.txt

# Prepare acoustic data

local/make_wav_and_utt2spk.py $src_dir/train
mv wav.scp data/train
mv utt2spk data/train

local/make_wav_and_utt2spk.py $src_dir/eval
mv wav.scp data/eval
mv utt2spk data/eval

local/make_wav_and_utt2spk.py $src_dir/devel
mv wav.scp data/dev
mv utt2spk data/dev
