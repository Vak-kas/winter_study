% MATLAB에서 파이썬 스크립트 호출 및 데이터 전달
keytext = 'hello';
ivtext = 'asdfbrea';
msg = 'seominjae';

command = ['python DES3.py "' keytext '" "' ivtext '" "' msg '"'];
system(command);

