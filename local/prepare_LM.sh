#!/bin/bash

. ./path.sh || exit 1
. ./cmd.sh || exit 1

nj=1       # number of parallel jobs - 1 is perfect for such a small data set


lm_src=/teamwork/t40511_asr/p/sami/lmdata/sme/wikipedia_10k.txt
arch_dir=/l/jpleino1/temp/sami_archives
lm_dir=/l/jpleino1/kaldi-trunk/egs/sami/data/local/lm
lang_dir=/teamwork/t40511_asr/p/sami/langdata


# Safety mechanism (possible running this script with modified arguments)
. utils/parse_options.sh || exit 1
[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; }


# Getting the phonemes
mkdir data/dict data/lang data/lang/local \
data/subword_wb_dict data/subword_wb_lang data/subword_wb_lang/local \
data/subword_lr_dict data/subword_lr_lang data/subword_lr_lang/local \
data/subword_l_dict data/subword_l_lang data/subword_l_lang/local \
data/subword_r_dict data/subword_r_lang data/subword_r_lang/local


echo
echo "===== PREPARING LANGUAGE DATA ====="
echo

extra=3

utils/prepare_lang.sh --num-extra-phone-disambig-syms $extra data/subword_wb_dict "<UNK>" data/subword_wb_lang/local data/subword_wb_lang



dir_wb=data/subword_wb_lang
tmpdir_wb=data/subword_wb_lang/local

# Overwrite L_disambig.fst
local/make_lfst_wb.py $(tail -n$extra $dir_wb/phones/disambig.txt) < $tmpdir_wb/lexiconp_disambig.txt | fstcompile --isymbols=$dir_wb/phones.txt --osymbols=$dir_wb/words.txt --keep_isymbols=false --keep_osymbols=false | fstaddselfloops  $dir_wb/phones/wdisambig_phones.int $dir_wb/phones/wdisambig_words.int | fstarcsort --sort_type=olabel > $dir_wb/L_disambig.fst

local/make_lfst_lr.py $(tail -n$extra $dir_lr/phones/disambig.txt) < $tmpdir_lr/lexiconp_disambig.txt | fstcompile --isymbols=$dir_lr/phones.txt --osymbols=$dir_lr/words.txt --keep_isymbols=false --keep_osymbols=false | fstaddselfloops  $dir_lr/phones/wdisambig_phones.int $dir_lr/phones/wdisambig_words.int | fstarcsort --sort_type=olabel > $dir_lr/L_disambig.fst 



echo
echo "===== MAKING G.fst ====="
echo

utils/format_lm.sh data/subword_wb_lang $lm_dir/sami_varikn_lm10_wb.lm.gz data/subword_wb_dict/lexicon.txt data/lang_test
mv data/lang_test/G.fst data/subword_wb_lang
rm -rf data/lang_test


echo
echo "===== TRI1 DECODING USING SUBWORDS WITH WORD BOUNDARIES ====="
echo

utils/mkgraph.sh data/subword_wb_lang exp/tri1 exp/tri1/graph_wb || exit 1
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri1/graph_wb data/eval exp/tri1/decode_wb

echo
echo "===== run.sh script is finished ====="
echo
