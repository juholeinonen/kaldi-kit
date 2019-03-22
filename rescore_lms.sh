#!/bin/bash

. ./path.sh || exit 1
. ./cmd.sh || exit 1

nj=1       # number of parallel jobs - 1 is perfect for such a small data set

##################################################################
################# CONFIGURATION PARAMETERS #######################
##################################################################
markings=(wb lr l r)
alphas=(1.0 0.5 0.2 0.1 0.05 0.02 0.01 0.005 0.002 0.001)
Ds=(0.5 0.2 0.1 0.05 0.02 0.01 0.005 0.002 0.001 0.0005 0.0002 0.0001)
language=sme
gender=F
lm_corpus=biglm.txt
comtypes=(ones none log)
# SOURCE FOLDERS BASED ON CONF PARAMETERS
lm_src=/scratch/elec/puhe/p/sami/lmdata/$language/$lm_corpus
lm_dir=/scratch/work/jpleino1/kaldi-trunk/egs/${language}_LMs

# Safety mechanism (possible running this script with modified arguments)
. utils/parse_options.sh || exit 1
[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; }

for comtype in ${comtypes[@]}; do
  for marking in ${markings[@]}; do
    for alpha in ${alphas[@]}; do
      str_alp="$(echo $alpha | sed 's/\./_/')"
      for D in ${Ds[@]}; do
        if ! [ -f ${lm_dir}/LMs_${comtype}/sme_varikn_lm10_${marking}_a${str_alp}_D${str_D}.lm.gz ]; then
          continue
        fi
        str_D="$(echo $D | sed 's/\./_/')"
        utils/build_const_arpa_lm ${lm_dir}/LMs_${comtype}/sme_varikn_lm10_${marking}_a${str_alp}_D${str_D}.lm.gz \
        data/${comtype}_${marking}_a${str_alp}_lang data/${comtype}_${marking}_${str_alp}_${str_D}_const_arpa
        steps/lmrescore_const_arpa.sh data/${comtype}_${marking}_a${str_alp}_lang data/${comtype}_${marking}_${str_alp}_${str_D}_const_arpa \
        data/eval exp/nnet3/tdnn1joku/decodese5gram exp/nnet3/tdnn1joku/rescored_${comtype}_${marking}_${str_alp}_${str_D}
      done
    done
  done
done

echo
echo "===== run.sh script is finished ====="
echo
