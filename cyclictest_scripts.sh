#!/bin/bash

#stress test할 test에 y로 설정, test하지않을 거라면 n로 설정
no_background='y'
list[0]=${no_background}
hackbench='y'
list[1]=${hackbench}
iperf='y'
list[2]=${iperf}
cpu_stress='y'
list[3]=${cpu_stress}
memory_stress='y'
list[4]=${memory_stress}
hdd_stress='y'
list[5]=${hdd_stress}
virtual_memory_stress='y'
list[6]=${virtual_memory_stress}
io_stress='y'
list[7]=${io_stress}

#stress test 시간 설정
time=600

#to call the cyclictest, cyclictest의 옵션을 바꾸고 싶다면 이 함수 내용을 수정!
function call_cyclictest(){
	sudo cyclictest -a -t -n -p99 -D ${time} -h400 -q > output
}

echo -n > test.txt

#cyclictest의 결과로부터 max latencies와 max latency를 가져와 출력
function print(){
  #sort -n : 숫자 정렬, tr : 치환 , Tail -n : n만큼의 라인 출력
  str=`grep "Max Latencies" $1 | tr " " "\n" | tail -16 | sed s/^0*//`
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

#0~list 크기 반복문
for ((i=0; i<${#list[*]}; i++))
do
	#no_background
	if [ ${list[${i}]} = 'y' ] && [ ${i} -eq 0 ]; then
		call_cyclictest
		print output no_background
	#hackbench	
	elif [ ${list[${i}]} = 'y' ] && [ ${i} -eq 1 ]; then
		hackbench -l 1000000 -s 1024 -P 0 &
		call_cyclictest
		print output hackbench
		kill_process hackbench
	#iperf
	elif [ ${list[${i}]} = 'y' ] && [ ${i} -eq 2 ]; then
		iperf -s &
		call_cyclictest
		print output iperf
		kill_process iperf
	#cpu_stress
	elif [ ${list[${i}]} = 'y' ] && [ ${i} -eq 3 ]; then
		stress --cpu 16 &
		call_cyclictest
		print output cpu_stress
		kill_process stress
	#memory_stress
	elif [ ${list[${i}]} = 'y' ] && [ ${i} -eq 4 ]; then
		stress --vm 3 --vm-bytes 1024m &
		call_cyclictest
		print output memory_stress
		kill_process stress
	#hdd_stress
	elif [ ${list[${i}]} = 'y' ] && [ ${i} -eq 5 ]; then
		stress --hdd 3 --hdd-bytes 1024m &
		call_cyclictest
		print output hdd_stress
		kill_process stress
	#virtual_memory_stress
	elif [ ${list[${i}]} = 'y' ] && [ ${i} -eq 6 ]; then
		stress-ng -t 1200 --vm 8 --vm-bytes 80% &
		call_cyclictest
		print output virtual_memory_stress
		kill_process stress
	#io_stress
	elif [ ${list[${i}]} = 'y' ] && [ ${i} -eq 7 ]; then
		stress -i 16 &
  		call_cyclictest
  		print output io_stress
  		kill_process stress
	fi
done
