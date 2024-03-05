> stats2.txt
for FILE in lip nmru random; do
    for DIR in 8 16;do
        cat ./result2/${FILE}/${DIR}/stats.txt | grep system.cpu.cpi >> stats2.txt
        cat ./result2/${FILE}/${DIR}/stats.txt | grep system.cpu.dcache.ReadReq.missRate::cpu.data >> stats2.txt
    done
done

cat stats2.txt | awk '{print $2}'|xargs -n2;

