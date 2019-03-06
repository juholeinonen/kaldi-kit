#!/bin/bash

test_sets=$1
nnet3_affix=$2
. ./path.sh
. ./cmd.sh

for datadir in ${test_sets}; do
   utils/copy_data_dir.sh data/$datadir data/${datadir}_hires
done

nj=1

for datadir in ${test_sets}; do
  steps/make_mfcc.sh --nj $nj --mfcc-config conf/mfcc_hires.conf \
    --cmd "$train_cmd" data/${datadir}_hires
  steps/compute_cmvn_stats.sh data/${datadir}_hires
  utils/fix_data_dir.sh data/${datadir}_hires
done

for data in ${test_sets}; do
  steps/online/nnet2/extract_ivectors_online.sh --cmd "$train_cmd" --nj 1 \
  data/${data}_hires exp/nnet3${nnet3_affix}/extractor \
  exp/nnet3${nnet3_affix}/ivectors_${data}_hires
done
