#!/bin/bash

if [ $# != 1 ]; then

  echo "You're doing this wrong"
  exit 1;
fi

wiki=$1

pre_corpus=pre_corpus.txt

# Create language model corpus
cp $wiki $pre_corpus
sed -i 's/\.//g' $pre_corpus
sed -i "s/'//g" $pre_corpus

cp $pre_corpus corpus.txt
sed -n '0~100p' $pre_corpus > variKN_discount.txt
sed '0~100d' $pre_corpus > corpus_variKN.txt

mkdir corpora
mv variKN_discount.txt corpora
mv corpus.txt corpora
mv corpus_variKN.txt corpora 

rm $pre_corpus
