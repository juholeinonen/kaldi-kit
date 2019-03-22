#!/bin/bash

if [ $# != 1 ]; then

  echo "You're doing this wrong"
  exit 1;
fi

lm_dir=$1

#
# Estimate language models.

MODEL_DIR="$lm_dir"

SOURCE_DIR="$lm_dir/corpus.txt"

################################################################################
# SRILM commands

estimate_srilm_full_vocab () {
	MODEL="$1.4bo.gz"
	shift

	echo "estimate_srilm $MODEL"

	ngram-count \
	  -order 3 \
	  -interpolate1 -interpolate2 -interpolate3 \
	  -gt4min 2 \
	  -limit-vocab \
	  -text - \
	  -lm "$MODEL" \
	  $*
}


################################################################################
# Separate models from each corpus

train_full_vocab () {
	if [[ -f $1 ]]
	then
		CAT="cat $1"
	else
		CAT="zcat $1.gz"
	fi
	MODEL="$2"
	echo "$MODEL :: $1"

	set +e

	DISCOUNTING="-kndiscount1 -kndiscount2 -kndiscount3"
	$CAT | grep -v '######' | estimate_srilm_full_vocab "$MODEL" $DISCOUNTING
	if [[ $? -ne 0 ]]
	then
		DISCOUNTING="-kndiscount1 -kndiscount2 -wbdiscount3"
		echo "Failed. Trying $DISCOUNTING."
		$CAT | grep -v '######' | estimate_srilm_full_vocab "$MODEL" $DISCOUNTING
	fi
	if [[ $? -ne 0 ]]
	then
		DISCOUNTING="-kndiscount1 -wbdiscount2 -wbdiscount3"
		echo "Failed. Trying $DISCOUNTING."
		$CAT | grep -v '######' | estimate_srilm_full_vocab "$MODEL" $DISCOUNTING
	fi
	if [[ $? -ne 0 ]]
	then
		DISCOUNTING="-wbdiscount1 -wbdiscount2 -wbdiscount3"
		echo "Failed. Trying $DISCOUNTING."
		$CAT | grep -v '######'| estimate_srilm_full_vocab "$MODEL" $DISCOUNTING
	fi

	set -e
}


################################################################################

train_full_vocab "$SOURCE_DIR" "$MODEL_DIR/kaldi-srilm"


