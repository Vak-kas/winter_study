keytext = 'samsjang';
ivtext = '12345678';
msg = 'python3x';

% 파이썬 스크립트 호출 및 데이터 전달
command = ['python AES.py "' keytext '" "' ivtext '" "' msg '"'];
system(command);