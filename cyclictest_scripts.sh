#!/bin/bash

#stress test할 test에 y로 설정, test하지않을 거라면 n로 설정
no_background='y'
hackbench='y'
iperf='y'
cpu_stress='y'
memory_stress='y'
hdd_stress='y'
virtual_memory_stress='y'
io_stress='y'

#stress test 시간 설정
time=600

echo -n > test.txt

list=(${no_background} ${hackbench} ${iperf} ${cpu_stress} ${memory_stress} ${hdd_stress} ${virtual_memory_stress} ${io_stress})

#cyclictest의 결과로부터 max latencies와 max latency를 가져와 출력
function print(){
  #sort -n : 숫자 정렬, tr : 치환 , Tail -n : n만큼의 라인 출력
  str=`grep "Max Latencies" $1 | sort -n | tr " " "\n" | tail -16 | sed s/^0*//`
  echo "**cyclictest result with $2**" >> test.txt
  echo -n "Max Latencies on each cores : " >> test.txt
  echo ${str} >> test.txt
  echo -n "Max latency : " >> test.txt
  echo "${str}"|sort -k1n|tail -1 >> test.txt
  echo >> test.txt
}

#to kill background process
function kill_process(){
  PID=`ps -ef | grep $1 | grep -v grep | awk '{print $2}'`
  tmp=${#PID}
  if [ ${tmp} -ne 0 ]; then
  kill -9 $PID
  fi
}

#no_background
  if [ ${list[0]} = 'y' ];then
  sudo cyclictest -a -t -n -p99 -D ${time} -h400 -q > output
  print output no_background
  fi

#hackbench
  if [ ${list[1]} = 'y' ];then
  hackbench -l 1000000 -s 1024 -P 0 &
  sudo cyclictest -a -t -n -p99 -D ${time} -h400 -q > output
  print output hackbench
  kill_process hackbench
fi

#iperf
if [ ${list[2]} = 'y' ];then
  iperf -s &
  sudo cyclictest -a -t -n -p99 -D ${time} -h400 -q > output
  print output iperf
  kill_process iperf
fi

#cpu_stress
if [ ${list[3]} = 'y' ];then
  stress --cpu 16 &
  sudo cyclictest -a -t -n -p99 -D ${time} -h400 -q > output
  print output cpu_stress
  kill_process stress
fi

#memory_stress
if [ ${list[4]} = 'y' ];then
  stress --vm 3 --vm-bytes 1024m &
  sudo cyclictest -a -t -n -p99 -D ${time} -h400 -q > output
  print output memory_stress
  kill_process stress
fi

#hdd_stress
if [ ${list[5]} = 'y' ];then
  stress --hdd 3 --hdd-bytes 1024m &
  sudo cyclictest -a -t -n -p99 -D ${time} -h400 -q > output
  print output hdd_stress
  kill_process stress
fi

#virtual_memory_stress
if [ ${list[6]} = 'y' ];then
  stress-ng -t 1200 --vm 8 --vm-bytes 80% &
  sudo cyclictest -a -t -n -p99 -D ${time} -h400 -q > output
  print output virtual_memory_stress
  kill_process stress
fi

#io_stress
if [ ${list[7]} = 'y' ];then
  stress -i 16 &
  sudo cyclictest -a -t -n -p99 -D ${time} -h400 -q > output
  print output io_stress
  kill_process stress
fi
