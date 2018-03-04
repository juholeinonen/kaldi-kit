#!/bin/bash

if [ $# != 5 ]; then

  echo "You're doing this wrong"
  exit 1;
fi

D=$1
str_D="$(echo $1 | sed 's/\./_/')"
str_alp="$(echo $2 | sed 's/\./_/')"
language=$3
marking=$4
comtype=$5
E=$(bc <<< 2*$D)

echo
echo "===== TRAIN VARIGRAM MODEL ====="
echo
varigram_kn -3 -C -a -O "0 0 1" -D $D -E $E -n 10 -o corpora_${comtype}/variKN_discount_${marking}_a${str_alp}.txt corpora_${comtype}/corpus_seg_${marking}_a${str_alp}.txt LMs_${comtype}/${language}_varikn_lm10_${marking}_a${str_alp}_D${str_D}.lm
gzip LMs_${comtype}/${language}_varikn_lm10_${marking}_a${str_alp}_D${str_D}.lm
