> stats.txt
for FILE in mm lfsr merge sieve spmv; do
    for DIR in 1_O3_8_1GHz_No 2_Mi_8_1GHz_No 3_O3_2_1GHz_No 4_O3_8_4GHz_No 5_O3_8_1GHz_256kB 6_O3_8_1GHz_2MB 7_O3_8_1GHz_16MB ;do
        cat ./result/${FILE}/${DIR}/stats.txt | grep system.mem_ctrls.dram.bwTotal::cpu.data >> stats.txt
        cat ./result/${FILE}/${DIR}/stats.txt | grep system.cpu.numBranches >> stats.txt
        cat ./result/${FILE}/${DIR}/stats.txt | grep system.cpu.dcache.ReadReq.missRate::cpu.data >> stats.txt
        cat ./result/${FILE}/${DIR}/stats.txt | grep system.cpu.cpi    >> stats.txt
        done
done

cat stats.txt | awk '{print $2}'|xargs -n4;
