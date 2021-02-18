#!/bin/bash
#
# cyclictest_scripts.sh
# : Perform cyclictest with stress tests and get the latencies as a result.
# email : 201804232@o.cnu.ac.kr

#cyclictest 시간 및 결과 파일명 설정
readonly CYCLICTEST_TIME=600
readonly FILENAME="cyclictest_result.txt"

#cyclictest의 옵션을 바꾸고 싶다면 이 함수 내용을 수정!
run_cyclictest(){
  sudo cyclictest -a -t -n -p99 -D ${CYCLICTEST_TIME} -h400 -q > output
}

print_latency(){
  #sort -n : 숫자 정렬, tr : 치환 , Tail -n : n만큼의 라인 출력
  local str=`grep "Max Latencies" $1 | tr " " "\n" | tail -16 | sed s/^0*//`
  {
  echo -n "**cyclictest result with "
  local _test_name=${list[${test_num[0]}]}
  echo -n ${_test_name}

  #백그라운드 테스트가 여러가지 일 때 ", "를 출력하기 위한 반복문
  for ((j=1; j<${#test_num[*]}; j++))
  do
    echo -n ", "
    _test_name=${list[${test_num[$j]}]}
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

print_stress_list(){
  echo "background stress test list"
  echo "0 : no_background"
  echo "1 : hackbench"
  echo "2 : iperf"
  echo "3 : cpu_stress"
  echo "4 : memory_stress"
  echo "5 : hdd_stress"
  echo "6 : virtual_memory_stress"
  echo "7 : io_stress"
}

cyclictest_with_stress(){
  for _test_index in $test_num
  do
    ${background_commands[${_test_index}]} &
  done

  run_cyclictest
}

kill_stress(){
  for _test_index in $test_num
  do
    kill -9 `ps | grep ${kill_commands[${_test_index}]} | awk '{print $1}'`
  done
}

main(){
  echo -n > ${FILENAME}

  if [ $1 == "--help" ] || [ $1 == "-h" ] ; then
    print_stress_list
    echo "Try --stress or -s option with stress numbers"
    echo "ex) ./cyclictest_scripts.sh --stress 3 5"

  elif [ $1 == "--stress" ] || [ $1 == "-s" ] ; then
    test_num=("${@:2}")
    cyclictest_with_stress
    print_latency output
    kill_stress

  else
    echo -n "cyclictest_scripts : Unknown command : "
    echo $@
    echo "cyclictest_scripts : Try \"./cyclictest_scripts.sh --help\" or \"./cyclictest_scripts.sh -h\""
  fi
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

main $@
