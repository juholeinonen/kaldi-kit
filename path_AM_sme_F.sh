#!/bin/bash

export PYTHONIOENCODING='utf-8'
export PATH="$PWD/utils:$PWD:$PATH"

module load kaldi/2017.08.09-53e5e12-GCC-5.4.0-mkl phonetisaurus anaconda3 anaconda2 srilm mitlm Morfessor sph2pipe variKN m2m-aligner et-g2p MorfessorJoint openfst/1.6.2-GCC-5.4.0

module list

