keytext = 'samsjang';
ivtext = '12345678';
filename = './plain.txt';

% 파이썬 스크립트 호출 및 데이터 전달
command = ['python DES3_for_File.py "' keytext '" "' ivtext '" "' filename '"'];
status = system(command);

if status == 0
    disp('Encryption Successful');
else
    disp('Encryption Failed');
end
