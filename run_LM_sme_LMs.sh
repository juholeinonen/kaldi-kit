#!/bin/bash

. ./path.sh || exit 1
. ./cmd.sh || exit 1

nj=1       # number of parallel jobs - 1 is perfect for such a small data set

##################################################################
################# CONFIGURATION PARAMETERS #######################
##################################################################
markings=(l r)
alphas=(1.0 0.5 0.2 0.1 0.05 0.02 0.01 0.005 0.002 0.001)
Ds=(0.5 0.2 0.1 0.05 0.02 0.01 0.005 0.002 0.001 0.0005 0.0002 0.0001)
language=sme
gender=F
lm_corpus=biglm.txt
comtypes=(log)
# SOURCE FOLDERS BASED ON CONF PARAMETERS
lm_src=/scratch/elec/puhe/p/sami/lmdata/$language/$lm_corpus
lm_dir=/scratch/work/jpleino1/kaldi-trunk/egs/${language}_LMs/corpora

# Safety mechanism (possible running this script with modified arguments)
. utils/parse_options.sh || exit 1
[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; }
############# No different comtypes here ##################
local/prepare_biglm.sh $lm_src 

echo
echo "===== LANGUAGE MODEL CREATION ====="
echo "===== MAKING lm.arpa ====="
echo
for comtype in ${comtypes[@]}; do
	for marking in ${markings[@]}; do
		for alpha in ${alphas[@]}; do
			local/run_morfessor.sh $marking $alpha $comtype
		done
	done
done

mkdir LMs_type
mkdir LMs_token
mkdir LMs_log
for comtype in ${comtypes[@]}; do
	for marking in ${markings[@]}; do
		for alpha in ${alphas[@]}; do
			for D in ${Ds[@]}; do
				local/run_variKN.sh $D $alpha $language $marking $comtype
			done
		done
	done
done
# Analyse perplexity
echo "===== Analysing model perplexeties ====="
for comtype in ${comtypes[@]}; do
	mkdir LMs_${comtype}/perplexeties LMs_${comtype}/perplexeties/devsets LMs_${comtype}/perplexeties/scores
	cp /scratch/elec/puhe/p/sami/lmdata/$language/wikipedia_small.txt LMs_${comtype}/perplexeties/devsets/
	cp /scratch/work/jpleino1/kaldi-trunk/egs/${language}_${gender}/data/dev/dev_corpus.txt LMs_${comtype}/perplexeties/devsets
	sed -i 's/\.//g' LMs_${comtype}/perplexeties/devsets/wikipedia_small.txt
	sed -i "s/'//g" LMs_${comtype}/perplexeties/devsets/wikipedia_small.txt
done
# Segmentind dev sets
for comtype in ${comtypes[@]}; do
	for marking in ${markings[@]}; do
		for alpha in ${alphas[@]}; do
			local/prep_perplex_set.sh LMs_${comtype}/perplexeties/devsets $marking $alpha $comtype
		done
	done
done
# Running preplexity on dev sets
for marking in ${markings[@]}; do
	for alpha in ${alphas[@]}; do
		str_alp="$(echo $alpha | sed 's/\./_/')"
		for D in ${Ds[@]}; do
			str_D="$(echo $D | sed 's/\./_/')"
			if [ $marking = "wb" ]; then
				str_D="$(echo $D | sed 's/\./_/')"
				perplexity -a LMs/${language}_varikn_lm10_${marking}_a${str_alp}_D${str_D}.lm.gz \
				-W wb.txt -t 2 LMs/perplexeties/devsets/corpus_seg_${marking}_a${str_alp}.txt \
				LMs/perplexeties/scores/scores_corpus_${marking}_a${str_alp}_D${str_D}.txt
				perplexity -a LMs/${language}_varikn_lm10_${marking}_a${str_alp}_D${str_D}.lm.gz \
				-W wb.txt -t 2 LMs/perplexeties/devsets/dev_corpus_${marking}_a${str_alp}.txt \
				LMs/perplexeties/scores/scores_dev_${marking}_a${str_alp}_D${str_D}.txt
			fi
			if [ $marking = "l" ]; then
				perplexity -a LMs/${language}_varikn_lm10_${marking}_a${str_alp}_D${str_D}.lm.gz \
				-t 1 -X mb_p.txt LMs/perplexeties/devsets/corpus_seg_${marking}_a${str_alp}.txt \
				LMs/perplexeties/scores/scores_corpus_${marking}_a${str_alp}_D${str_D}.txt
                                perplexity -a LMs/${language}_varikn_lm10_${marking}_a${str_alp}_D${str_D}.lm.gz \
				-t 1 -X mb_p.txt LMs/perplexeties/devsets/dev_corpus_${marking}_a${str_alp}.txt \
				LMs/perplexeties/scores/scores_dev_${marking}_a${str_alp}_D${str_D}.txt
			fi
			if [ $marking = "lr" ] || [ $marking = "r" ]; then
				perplexity -a LMs/${language}_varikn_lm10_${marking}_a${str_alp}_D${str_D}.lm.gz \
				-t 1 -X mb_s.txt LMs/perplexeties/devsets/corpus_seg_${marking}_a${str_alp}.txt \
				LMs/perplexeties/scores/scores_corpus_${marking}_a${str_alp}_D${str_D}.txt
                                perplexity -a LMs/${language}_varikn_lm10_${marking}_a${str_alp}_D${str_D}.lm.gz \
				-t 1 -X mb_s.txt LMs/perplexeties/devsets/dev_corpus_${marking}_a${str_alp}.txt \
				LMs/perplexeties/scores/scores_dev_${marking}_a${str_alp}_D${str_D}.txt
			fi
		done
	done
done
# Building and pruning a word model
local/run_SRILM.sh $lm_dir
ngram -order 3 -unk -lm "$lm_dir/kaldi-srilm.4bo.gz" -prune 5e-10 -write-lm "kaldi_srilm-prune=5e10.4bo"
mv kaldi_srilm-prune=5e10.4bo data/local/lm
local/lexicon.py $lm_dir/corpus.txt
mv lexicon.txt data/dict


echo
echo "===== PREPARING LANGUAGE DATA AND MAKING G.fst ====="
echo

extra=3

utils/prepare_lang.sh data/dict "<UNK>" data/lang/local data/lang

utils/format_lm_sri.sh data/lang $lm_dir/sami_srilm-prune=5e10.4bo data/lang_test
mv data/lang_test/G.fst data/lang
rm -rf data/lang_test

for marking in ${markings[@]}; do
	utils/prepare_lang.sh --num-extra-phone-disambig-syms $extra data/subword_${marking}_dict "<UNK>" data/subword_${marking}_lang/local data/subword_${marking}_lang

	dir_marking=data/subword_${marking}_lang
	tmpdir_marking=data/subword_${marking}_lang/local


	# Overwrite L_disambig.fst
	local/make_lfst_${marking}.py $(tail -n$extra $dir_marking/phones/disambig.txt) < $tmpdir_marking/lexiconp_disambig.txt | fstcompile --isymbols=$dir_marking/phones.txt --osymbols=$dir_marking/words.txt --keep_isymbols=false --keep_osymbols=false | fstaddselfloops  $dir_marking/phones/wdisambig_phones.int $dir_marking/phones/wdisambig_words.int | fstarcsort --sort_type=olabel > $dir_marking/L_disambig.fst


	utils/format_lm.sh data/subword_${marking}_lang $lm_dir/sami_varikn_lm10_${marking}.lm.gz data/subword_${marking}_dict/lexicon.txt data/lang_test
	mv data/lang_test/G.fst data/subword_${marking}_lang
	rm -rf data/lang_test
done	

echo
echo "===== run.sh script is finished ====="
echo
