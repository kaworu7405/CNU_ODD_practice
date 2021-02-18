#!/bin/bash
#
# cyclictest_scripts.sh
# usage : Perform cyclictest with stress tests and get the latencies as a result.
# email : 201804232@o.cnu.ac.kr

#cyclictest 시간 및 결과 파일명 설정
readonly CYCLICTEST_TIME=600
readonly FILENAME="cyclictest_result.txt"

#cyclictest의 옵션을 바꾸고 싶다면 이 함수 내용을 수정!
f_cyclictest(){
  sudo cyclictest -a -t -n -p99 -D ${CYCLICTEST_TIME} -h400 -q > output
}

f_print_latency(){
  #sort -n : 숫자 정렬, tr : 치환 , Tail -n : n만큼의 라인 출력
  local str=`grep "Max Latencies" $1 | tr " " "\n" | tail -16 | sed s/^0*//`
  {
  echo -n "**cyclictest result with "
  local _test_num=(${tests[$2]})
  local _test_name=${list[${_test_num[0]}]}
  echo -n ${_test_name}

  #백그라운드 테스트가 여러가지 일 때 ", "를 출력하기 위한 반복문
  for ((j=1; j<${#_test_num[*]}; j++))
  do
    echo -n ", "
    _test_name=${list[${_test_num[$j]}]}
    echo -n ${_test_name}
  done

  echo "**"
  echo -n "Max Latencies on each cores : "
  echo ${str}
  echo -n "Max latency : "
  echo "${str}"|sort -k1n|tail -1
  echo
  } >> ${FILENAME}
}

f_cyclictest_with_stress(){
  local _test_num=$(echo ${tests[$1]} | tr " " "\n")

  for _test_index in $_test_num
  do
    ${background_commands[${_test_index}]} &
  done

  f_cyclictest
}

f_kill_stress(){
  local _test_num=$(echo ${tests[$1]} | tr " " "\n")

  for _test_index in $_test_num
  do
    kill -9 `ps | grep ${kill_commands[${_test_index}]} | awk '{print $1}'`
  done
}

main(){
  echo -n > ${FILENAME}

  for ((i=0; i<${#tests[*]}; i++))
  do
    f_cyclictest_with_stress ${i}
    f_print_latency output ${i}	
    f_kill_stress ${i}
  done
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
background_commands[0]=""
background_commands[1]="hackbench -l 1000000 -s 1024 -P 0"
background_commands[2]="iperf -s"
background_commands[3]="stress --cpu 16"
background_commands[4]="stress --vm 3 --vm-bytes 1024m"
background_commands[5]="stress --hdd 3 --hdd-bytes 1024m"
background_commands[6]="stress-ng -t 1200 --vm 8 --vm-bytes 80%"
background_commands[7]="stress -i 16"

#백그라운드 kill 명령어
kill_commands[0]=""
kill_commands[1]="hackbench"
kill_commands[2]="iperf"
kill_commands[3]="stress"
kill_commands[4]="stress"
kill_commands[5]="stress"
kill_commands[6]="stress"
kill_commands[7]="stress"

main
