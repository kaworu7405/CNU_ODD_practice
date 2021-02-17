#!/bin/bash

#stress test 시간 설정
readonly TIME=10
readonly FILENAME="test.txt"

#to call the cyclictest, cyclictest의 옵션을 바꾸고 싶다면 이 함수 내용을 수정!
fCyclictest(){
  sudo cyclictest -a -t -n -p99 -D ${TIME} -h400 -q > output
}

#가능한 백그라운드 테스트 목록
list[0]="no_background"
list[1]="hackbench"
list[2]="iperf"
list[3]="cpu_stress"
list[4]="memory_stress"
list[5]="hdd_stress"
list[6]="virtual_memory_stress"
list[7]="io_stress"

#위 가능한 백그라운드 테스트 인덱스를 이용해 background를 실행할 순서대로 배열에 저장해주세요. 띄어쓰기로 구분합니다.
tests[0]="0" #no_background
tests[1]="1" #hackbench
tests[2]="2" #iperf
tests[3]="3" #cpu_stress
tests[4]="4" #memory_stress
tests[5]="5" #hdd_stress
tests[6]="6" #virtual_memory_stress
tests[7]="7" #io_stress
tests[8]="3 5" #cpu_stress and hdd_stress

#백그라운드 명령어 리스트
commands[0]=""
commands[1]="hackbench -l 1000000 -s 1024 -P 0"
commands[2]="iperf -s"
commands[3]="stress --cpu 16"
commands[4]="stress --vm 3 --vm-bytes 1024m"
commands[5]="stress --hdd 3 --hdd-bytes 1024m"
commands[6]="stress-ng -t 1200 --vm 8 --vm-bytes 80%"
commands[7]="stress -i 16"

#백그라운드 kill 명령어
kill_commands[0]=""
kill_commands[1]="hackbench"
kill_commands[2]="iperf"
kill_commands[3]="stress"
kill_commands[4]="stress"
kill_commands[5]="stress"
kill_commands[6]="stress"
kill_commands[7]="stress"

echo -n > ${FILENAME}

#cyclictest의 결과로부터 max latencies와 max latency를 가져와 출력
fPrintLatency(){
  #sort -n : 숫자 정렬, tr : 치환 , Tail -n : n만큼의 라인 출력
  str=`grep "Max Latencies" $1 | tr " " "\n" | tail -16 | sed s/^0*//`
  {
  echo -n "**cyclictest result with "
  local _test_num=(${tests[$2]})
  echo -n ${list[${_test_num[0]}]}

  for ((j=1; j<${#_test_num[*]}; j++))
  do
    echo -n ", "
    echo -n ${list[${_test_num[$j]}]}
  done

  echo "**"
  echo -n "Max Latencies on each cores : "
  echo ${str}
  echo -n "Max latency : "
  echo "${str}"|sort -k1n|tail -1
  echo
  } >> ${FILENAME}
}

#background test 실행 및 cyclictest 실행
fCyclictestWithStress(){
  local _test_num=$(echo ${tests[$1]} | tr " " "\n")

  for index in $_test_num
  do
    ${commands[${index}]} &
  done

  fCyclictest
}

fKillStress(){
  local _test_num=$(echo ${tests[$1]} | tr " " "\n")

  for index in $_test_num
  do
    kill -9 `ps | grep ${kill_commands[${index}]} | awk '{print $1}'`
  done
}

for ((i=0; i<${#tests[*]}; i++))
do
  fCyclictestWithStress ${i}
  fPrintLatency output ${i}	
  fKillStress ${i}
done
