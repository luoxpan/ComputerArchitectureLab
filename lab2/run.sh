#!/bin/bash

GEM5_BASE=~/gem5
GEM5_OPT=~/gem5/build/X86/gem5.opt 
SRC_DIR=~/lab2/cs251a-microbench-master
RESULT_DIR=~/lab2/result
SE1_PY=~/gem5/configs/example/se.py
SE1_PY=~/gem5/configs/example/se1.py
SE2_PY=~/gem5/configs/example/se2.py

M5OUT=m5out
OUT_TXT=${M5OUT}/stats.txt
OUT_INI=${M5OUT}/config.ini
rm -rf ${RESULT_DIR}/*
for FILE in mm lfsr merge sieve spmv; do
    mkdir -p ${RESULT_DIR}/${FILE}
done

for FILE in mm lfsr merge sieve spmv; do
    #O3 8 1GHz No
    ${GEM5_OPT} ${SE1_PY} --cmd=${SRC_DIR}/${FILE} --cpu-type=DerivO3CPU \
        --l1d_size=64kB --l1i_size=64kB --caches \
        --sys-clock=1GHz --cpu-clock=1GHz --mem-type=DDR3_1600_8x8
    mkdir ${RESULT_DIR}/${FILE}/1_O3_8_1GHz_No
    cp  ${OUT_TXT} ${OUT_INI} ${RESULT_DIR}/${FILE}/1_O3_8_1GHz_No

    #MinorCPU 8 1GHz No
    ${GEM5_OPT} ${SE_PY} --cmd=${SRC_DIR}/${FILE} --cpu-type=MinorCPU \
        --l1d_size=64kB --l1i_size=64kB --caches \
        --sys-clock=1GHz --cpu-clock=1GHz --mem-type=DDR3_1600_8x8
    mkdir ${RESULT_DIR}/${FILE}/2_Mi_8_1GHz_No
    cp ${OUT_TXT} ${OUT_INI} ${RESULT_DIR}/${FILE}/2_Mi_8_1GHz_No

    #O3 2 1GHz No
    ${GEM5_OPT} ${SE2_PY} --cmd=${SRC_DIR}/${FILE} --cpu-type=DerivO3CPU \
        --l1d_size=64kB --l1i_size=64kB --caches \
        --sys-clock=1GHz --cpu-clock=1GHz --mem-type=DDR3_1600_8x8
    mkdir ${RESULT_DIR}/${FILE}/3_O3_2_1GHz_No
    cp ${OUT_TXT} ${OUT_INI} ${RESULT_DIR}/${FILE}/3_O3_2_1GHz_No

    #O3 8 4GHz No
    ${GEM5_OPT} ${SE1_PY} --cmd=${SRC_DIR}/${FILE} --cpu-type=DerivO3CPU \
        --l1d_size=64kB --l1i_size=64kB --caches \
        --sys-clock=4GHz --cpu-clock=4GHz --mem-type=DDR3_1600_8x8
    mkdir ${RESULT_DIR}/${FILE}/4_O3_8_4GHz_No
    cp ${OUT_TXT} ${OUT_INI} ${RESULT_DIR}/${FILE}/4_O3_8_4GHz_No

    #O3 8 1GHz 256kB
    ${GEM5_OPT} ${SE1_PY} --cmd=${SRC_DIR}/${FILE} --cpu-type=DerivO3CPU \
        --l1d_size=64kB --l1i_size=64kB --caches --l2_size=256kB --l2cache \
        --sys-clock=1GHz --cpu-clock=1GHz --mem-type=DDR3_1600_8x8
    mkdir ${RESULT_DIR}/${FILE}/5_O3_8_1GHz_256kB
    cp ${OUT_TXT} ${OUT_INI} ${RESULT_DIR}/${FILE}/5_O3_8_1GHz_256kB

    #O3 8 1GHz 2MB
    ${GEM5_OPT} ${SE1_PY} --cmd=${SRC_DIR}/${FILE} --cpu-type=DerivO3CPU \
        --l1d_size=64kB --l1i_size=64kB --caches --l2_size=2MB --l2cache \
        --sys-clock=1GHz --cpu-clock=1GHz --mem-type=DDR3_1600_8x8
    mkdir ${RESULT_DIR}/${FILE}/6_O3_8_1GHz_2MB
    cp ${OUT_TXT} ${OUT_INI} ${RESULT_DIR}/${FILE}/6_O3_8_1GHz_2MB

    #O3 8 1GHz 16MB
    ${GEM5_OPT} ${SE1_PY} --cmd=${SRC_DIR}/${FILE} --cpu-type=DerivO3CPU \
        --l1d_size=64kB --l1i_size=64kB --caches --l2_size=16MB --l2cache \
        --sys-clock=1GHz --cpu-clock=1GHz --mem-type=DDR3_1600_8x8
    mkdir ${RESULT_DIR}/${FILE}/7_O3_8_1GHz_16MB
    cp  ${OUT_TXT} ${OUT_INI} ${RESULT_DIR}/${FILE}/7_O3_8_1GHz_16MB
done

