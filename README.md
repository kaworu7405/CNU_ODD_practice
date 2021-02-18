
How to use
  
1. cyclictest_scripts.sh가 있는 폴더에서 ./cyclictest_scripts.sh --help를 명령어로 입력하여 각 스트레스 테스트의 숫자를 확인합니다.

2. ./cyclictest_scripts.sh --stress [스트레스 테스트의 숫자] 를 명령어로 입력하여 원하는 스트레스 테스트를 백그라운드로 실행하여 cyclictest 결과(latencies)를 얻을 수 있습니다.

3. 스트레스 테스트의 숫자는 띄어쓰기 한 칸으로 구별됩니다.

4. 결과는 cyclictest_result.txt 파일에 출력됩니다.

How to modify

1. stress test는 10분(=600s)으로 설정되어있습니다. 원하는 시간이 있다면 CYCLICTEST_TIME 상수값을 변경합니다.

2. 결과가 출력되는 파일명은 FILENAME 값을 변경합니다.

3. run_cyclictest 함수에서 cyclictest의 옵션을 바꿀 수 있습니다.
