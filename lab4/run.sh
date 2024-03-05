for num in 1 2 3;do
    cat stats${num}.txt | grep system.cpu_cluster.cpus.cpi|awk '{if(NR>=2&&NR<=7){print $2}}'
    cat stats${num}.txt | grep simSeconds|awk '{if(NR>=2&&NR<=7){print $2}}'
    cat stats${num}.txt | grep system.cpu_cluster.cpus.numInsts|awk '{if(NR>=2&&NR<=7){print $2}}'
done