#!/bin/bash

steps/scoring/score_kaldi_wer.sh --min_lmwt 2 --max_lmwt 18 "$@"
steps/scoring/score_kaldi_cer.sh --min_lmwt 2 --max_lmwt 18 --stage 2 "$@"
