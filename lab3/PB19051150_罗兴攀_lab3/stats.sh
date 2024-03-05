> stats.txt
for FILE in lip lru nmru random; do
    for DIR in 2 4 8 16;do
        cat ./result/${FILE}/${DIR}/stats.txt | grep system.cpu.cpi >> stats.txt
        cat ./result/${FILE}/${DIR}/stats.txt | grep system.cpu.dcache.ReadReq.missRate::cpu.data >> stats.txt
    done
done

cat stats.txt | awk '{print $2}'|xargs -n2;