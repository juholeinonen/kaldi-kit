#!/bin/bash

LAST=""
declare -A jobmap
ORIG_IFS=$IFS
JOB_PREFIX=$(cat id)_

function join { local IFS="$1"; shift; echo "$*"; }

function job {

SDG_LOG_DIR=${SDG_LOG_DIR:-log}
mkdir -p $SDG_LOG_DIR

sdg_name=$1
mem=$2
time=$3
after=$4

shift 4

declare -a dep

case $after in
"NONE")
;;
"LAST")
  if [ -n "$LAST" ]; then
      dep+=($LAST)
  fi
;;
*)
IFS=',' read -r -a names <<< "$after"
for n in ${names[@]}; do
    if [ -n "${jobmap[$n]}" ]; then
        dep+=(${jobmap["$n"]})
    else
        echo "Warning, did not find job '${n}' for dependency"
    fi
done
;;
esac

if [ -n "${DEP_LIST:-}" ]; then
IFS=',' read -r -a ids <<< "$DEP_LIST"
for i in ${ids[@]}; do
    dep+=($i)
done
fi

deparg=""
if [ ${#dep[@]} -gt 0 ]
then
    depp=$(join : "${dep[@]}")
    deparg="--dependency=afterok:$depp"
fi

extrashortpart=""
if [ ${time} -le 4 ]
then
    extrashortpart=",short-ivb,short-wsm,short-hsw"
fi
if [ ${mem} -ge 60 ]
then
    extrashortpart="$extrashortpart,hugemem"
fi

extra_args=${SLURM_EXTRA_ARGS:-}
#echo sbatch -x pe63 -p coin,batch-ivb,batch-wsm,batch-hsw${extrashortpart} --job-name="${JOB_PREFIX^^}${sdg_name}" -e "$SDG_LOG_DIR/${sdg_name}-%j.out" -o "$SDG_LOG_DIR/${sdg_name}-%j.out" -t ${time}:00:00 $extra_args --mem-per-cpu ${mem}G $deparg "${@}"
ret=$(sbatch -xwsm136 -p coin,batch-ivb,batch-wsm,batch-hsw${extrashortpart} --job-name="${JOB_PREFIX^^}${sdg_name}" -e "$SDG_LOG_DIR/${sdg_name}-%j.out" -o "$SDG_LOG_DIR/${sdg_name}-%j.out" -t ${time}:00:00 $extra_args --mem-per-cpu ${mem}G $deparg "${@}")

echo $ret
rid=$(echo $ret | awk '{print $4;}')
LAST=$rid

jobmap["$sdg_name"]=$rid

echo $rid >> $SDG_LOG_DIR/slurm_ids
IFS=$ORIG_IFS
}


