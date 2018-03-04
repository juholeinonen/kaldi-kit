#!/bin/bash -e

#SBATCH --partition gpu
#SBATCH --time=02-00
#SBATCH --gres=gpu:teslap100:1
#SBATCH --mem=10G
#SBATCH -o /scratch/work/jpleino1/log/char-rnnlm-%j.log
#SBATCH -e /scratch/work/jpleino1/log/char-rnnlm-%j.log

module purge
module purge
module load srilm
module load cudnn
module load libgpuarray
module load Theano
module load TheanoLM
# source /scratch/work/gangirs1/venv/bin/activate
# export PYTHONPATH="${PYTHONPATH}:/scratch/work/gangirs1/theanolm_siva/theanolm"
# export PATH="${PATH}:${PYTHONPATH}:/scratch/work/gangirs1/theanolm_siva/theanolm/bin"
declare -a DEVICES=("cuda0")
echo "${LD_LIBRARY_PATH}"
which theanolm
theanolm version

# Load common functions.
source "/scratch/work/jpleino1/kaldi-trunk/egs/sme_LMs/local/configure-theano.sh"

theanolm train \
  model_t.h5 \
  --training-set corpora_rnnlm/char_corpus_variKN.txt \
  --validation-file corpora_rnnlm/char_variKN_discount.txt \
  --architecture lstm1500 \
  --learning-rate 0.1 \
  --optimization-method adagrad \
  --validation-frequency 1 \
  --patience 0 \
  --cost cross-entropy
