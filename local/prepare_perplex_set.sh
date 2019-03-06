#!/bin/bash

if [ $# != 4 ]; then

  echo "You're doing this wrong"
  exit 1;
fi
lm_dir=$1
marking=$2
alpha=$3
comtype=$4
str_alp="$(echo $alpha | sed 's/\./_/')"
if [ $marking = "lr" ]; then
	separator="+ +"
fi

if [ $marking = "r" ]; then
	separator="+ "
fi

if [ $marking = "l" ]; then
	separator=" +"
fi

if [ $marking = "wb" ]; then
	separator=" "
	format="{analysis} <w> "
else
	format="{analysis} "
fi


echo
echo "===== SEGMENTING CORPUS ====="
echo
LC_ALL= morfessor-segment -l Morfessor_${comtype}/model_alp_${str_alp}.bin --output-format="$format" --output-format-separator "$separator" --output-newlines $lm_dir/wikipedia_small.txt > $lm_dir/corpus_seg_${marking}_a${str_alp}.txt

LC_ALL= morfessor-segment -l Morfessor_${comtype}/model_alp_${str_alp}.bin --output-format="$format" --output-format-separator "$separator" --output-newlines $lm_dir/dev_corpus.txt > $lm_dir/dev_corpus_${marking}_a${str_alp}.txt

if [ $marking = "wb" ]; then
	sed -i 's/^/<s> <w> /' $lm_dir/corpus_seg_${marking}_a${str_alp}.txt
	sed -i 's/$/<\/s>/' $lm_dir/corpus_seg_${marking}_a${str_alp}.txt
	
	sed -i 's/^/<s> <w> /' $lm_dir/dev_corpus_${marking}_a${str_alp}.txt
	sed -i 's/$/<\/s>/' $lm_dir/dev_corpus_${marking}_a${str_alp}.txt
else
	sed -i 's/^/<s> /' $lm_dir/corpus_seg_${marking}_a${str_alp}.txt
	sed -i 's/$/<\/s>/' $lm_dir/corpus_seg_${marking}_a${str_alp}.txt

	sed -i 's/^/<s> /' $lm_dir/dev_corpus_${marking}_a${str_alp}.txt
	sed -i 's/$/<\/s>/' $lm_dir/dev_corpus_${marking}_a${str_alp}.txt
fi
