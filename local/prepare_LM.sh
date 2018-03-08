#!/bin/bash

if [ $# != 5 ]; then

  echo "You're doing this wrong"
  exit 1;
fi

. ./path.sh || exit 1
. ./cmd.sh || exit 1

nj=1       # number of parallel jobs - 1 is perfect for such a small data set

language=$1
comtype=$2
marking=$3
str_alp="$(echo $4 | sed 's/\./_/')"
str_D="$(echo $5 | sed 's/\./_/')"

langdir=/scratch/elec/puhe/p/sami/langdata/kaldi/${language}/subword_dict


# Safety mechanism (possible running this script with modified arguments)
. utils/parse_options.sh || exit 1
#[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; }
[ -f path.sh ] && . ./path.sh #source the path.
. parse_options.sh || exit 1;

# Prepapring folders
mkdir data/langs_${comtype} data/dicts_${comtype}
mkdir data/langs_${comtype}/subword_${marking}_langs data/dicts_${comtype}/subword_${marking}_dicts
mkdir data/langs_${comtype}/subword_${marking}_langs/a_${str_alp}
mkdir data/langs_${comtype}/subword_${marking}_langs/a_${str_alp}/local
mkdir data/dicts_${comtype}/subword_${marking}_dicts/a_${str_alp}
mkdir data/langs_${comtype}/subword_${marking}_langs/a_${str_alp}/Gfsts



dir=data/langs_${comtype}/subword_${marking}_langs/a_${str_alp}
tmpdir=data/langs_${comtype}/subword_${marking}_langs/a_${str_alp}/local
lexdir=data/dicts_${comtype}/subword_${marking}_dicts/a_${str_alp}

# Copying phones and lexicon
cp ${langdir}/* ${lexdir}
cp ../${language}_LMs/dicts_${comtype}/subword_${marking}_dicts/a_${str_alp}/lexicon.txt \
${lexdir}
echo
echo "===== PREPARING LANGUAGE DATA ====="
echo

extra=3


utils/prepare_lang.sh --num-extra-phone-disambig-syms $extra \
${lexdir} "<UNK>" ${tmpdir} ${dir} 



# Overwrite L_disambig.fst
local/make_lfst_${marking}.py $(tail -n$extra $dir/phones/disambig.txt) < $tmpdir/lexiconp_disambig.txt | fstcompile --isymbols=$dir/phones.txt --osymbols=$dir/words.txt --keep_isymbols=false --keep_osymbols=false | fstaddselfloops  $dir/phones/wdisambig_phones.int $dir/phones/wdisambig_words.int | fstarcsort --sort_type=olabel > $dir/L_disambig.fst

echo
echo "===== MAKING G.fst ====="
echo

utils/format_lm.sh $dir ../${language}_LMs/LMs_${comtype}/${language}_varikn_lm10_${marking}_a${str_alp}_D${str_D}.lm.gz $lexdir/lexicon.txt \
data/langs_${comtype}/subword_${marking}_langs/a_${str_alp}_test
mv data/langs_${comtype}/subword_${marking}_langs/a_${str_alp}_test/G.fst $dir/Gfsts/G_a${str_alp}_D${str_D}.fst
ln -s Gfsts/G_a${str_alp}_D${str_D}.fst $dir/G.fst
rm -rf data/langs_${comtype}/subword_${marking}_langs/a_${str_alp}_test

echo
echo "===== run.sh script is finished ====="
echo
