#!/bin/bash

if [ $# != 3 ]; then

  echo "You're doing this wrong"
  exit 1;
fi

marking=$1
alpha=$2
comtype=$3
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
echo "===== TRAINING MORFESSOR ====="
echo
if ! [ -f Morfessor_${comtype}/model_alp_${str_alp}.bin ]; then
	morfessor-train --encoding=utf-8 --logfile=Morfessor_${comtype}/log_${str_alp}.log --corpusweight=$alpha -s Morfessor_${comtype}/model_alp_${str_alp}.bin -d ${comtype} corpora_${comtype}/corpus_variKN.txt
fi

echo
echo "===== SEGMENTING CORPUS ====="
echo
LC_ALL= morfessor-segment -l Morfessor_${comtype}/model_alp_${str_alp}.bin --output-format="$format" --output-format-separator "$separator" --output-newlines corpora_${comtype}/corpus_variKN.txt > corpora_${comtype}/corpus_seg_${marking}_a${str_alp}.txt

LC_ALL= morfessor-segment -l Morfessor_${comtype}/model_alp_${str_alp}.bin --output-format="$format" --output-format-separator "$separator" --output-newlines corpora_${comtype}/variKN_discount.txt > corpora_${comtype}/variKN_discount_${marking}_a${str_alp}.txt

local/lexicon.py corpora_${comtype}/corpus_seg_${marking}_a${str_alp}.txt
if [ $marking = "wb" ]; then
	sed -i 's/<w> < w >/<w> SIL/g' lexicon.txt
	sed -i 's/^/<s> <w> /' corpora_${comtype}/corpus_seg_${marking}_a${str_alp}.txt
	sed -i 's/$/<\/s>/' corpora_${comtype}/corpus_seg_${marking}_a${str_alp}.txt
	
	sed -i 's/^/<s> <w> /' corpora_${comtype}/variKN_discount_${marking}_a${str_alp}.txt
	sed -i 's/$/<\/s>/' corpora_${comtype}/variKN_discount_${marking}_a${str_alp}.txt
else
	sed -i 's/^/<s> /' corpora_${comtype}/corpus_seg_${marking}_a${str_alp}.txt
	sed -i 's/$/<\/s>/' corpora_${comtype}/corpus_seg_${marking}_a${str_alp}.txt

	sed -i 's/^/<s> /' corpora_${comtype}/variKN_discount_${marking}_a${str_alp}.txt
	sed -i 's/$/<\/s>/' corpora_${comtype}/variKN_discount_${marking}_a${str_alp}.txt
fi
mkdir dicts_${comtype}
mkdir dicts_${comtype}/subword_${marking}_dicts
mkdir dicts_${comtype}/subword_${marking}_dicts/a_${str_alp}
mv lexicon.txt dicts_${comtype}/subword_${marking}_dicts/a_${str_alp}
