#!/bin/bash

#SBATCH --partition batch
#SBATCH --time=12:00:00    # 5 hours
#SBATCH --mem-per-cpu=1024    # 1024MB of memory
#SBATCH -o /scratch/work/jpleino1/log/logtype-%j.log
#SBATCH -e /scratch/work/jpleino1/log/logtype-%j.log

. ./path.sh || exit 1
. ./cmd.sh || exit 1

nj=1       # number of parallel jobs - 1 is perfect for such a small data set

##################################################################
################# CONFIGURATION PARAMETERS #######################
##################################################################
markings=(l)
alphas=(1.0 0.5 0.2 0.1 0.05 0.02) # 0.01 0.005 0.002 0.001 
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

echo
echo "===== LANGUAGE MODEL CREATION ====="
echo "===== MAKING lm.arpa ====="
echo
for comtype in ${comtypes[@]}; do
	for marking in ${markings[@]}; do
		for alpha in ${alphas[@]}; do
			for D in ${Ds[@]}; do
				local/run_variKN.sh $D $alpha $language $marking $comtype
			done
		done
	done
done
