#!/bin/bash

GEM5_BASE=~/gem5
GEM5_OPT=~/gem5/build/X86/gem5.opt 
SRC_DIR=~/lab3/src
RESULT_DIR=~/lab3/result2
SE_PY=~/gem5/configs/example/se_lab3

M5OUT=m5out
OUT_TXT=${M5OUT}/stats.txt
OUT_INI=${M5OUT}/config.ini
rm -rf ${RESULT_DIR}/*
FILE=mm

for REL in nmru lip; do
    for ASSOC in 8; do
        ${GEM5_OPT} ${SE_PY}_${REL}.py --cmd=${SRC_DIR}/${FILE} --cpu-type=DerivO3CPU \
            --l1d_size=64kB --l1d_assoc=${ASSOC} --l1i_size=64kB --caches \
            --sys-clock=2.2GHz --cpu-clock=2.2GHz
        mkdir -p ${RESULT_DIR}/${REL}/${ASSOC}
        cp  ${OUT_TXT} ${OUT_INI} ${RESULT_DIR}/${REL}/${ASSOC}
    done
done

REL=random
ASSOC=16
${GEM5_OPT} ${SE_PY}_${REL}.py --cmd=${SRC_DIR}/${FILE} --cpu-type=DerivO3CPU \
            --l1d_size=64kB --l1d_assoc=${ASSOC} --l1i_size=64kB --caches \
            --sys-clock=2.2GHz --cpu-clock=2.2GHz
        mkdir -p ${RESULT_DIR}/${REL}/${ASSOC}
        cp  ${OUT_TXT} ${OUT_INI} ${RESULT_DIR}/${REL}/${ASSOC}

