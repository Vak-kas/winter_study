clear variables;
clc;

%% Setting var
SNR_dB = 20;
SNR_linear = 10^(SNR_dB/10); %Signal Power
M = 4; % 기본적인 이 실험은 QPSK로 만 진행할 예정
keytext = "ICIS";
ivtext = "1234";


%% bit_data 불러오기
original_bit_data= readFile("./plain.txt");
tmp = DES3(original_bit_data, keytext, ivtext);
nSymbols = length(original_bit_data); % 전체 비트 개수
nRows = nSymbols/7; %전체 글자 수
flag = false; %전체 글자수가 짝수면 false, 홀수면 true



%% 변조
if M == 4
    if mod(nSymbols, 2) ~=0 %글자수가 홀수라면
        bit_data = [original_bit_data, 0]; %비트배열 맨 뒤에 0 추가
        nSymbols = nSymbols +1; %전체 심볼수 1증가
        flag = true; %전체 글자수는 홀수라고 flag 값 변경
    else
        bit_data = original_bit_data;
    end
    
    modulated_symbol = QPSK_Mapper(bit_data);  %QPSK 맵핑
elseif M == 16
elseif M==2
    
end

%% Transmission System
%r(n) = h(n) * y(n) + z(n)
transmit_power = SNR_linear; % 출력세기 (y(n))
h = sqrt(1/2)*(randn(1, length(modulated_symbol)) + 1j*randn(1, length(modulated_symbol)) ); %무선 채널의 개수(h(n))
transmission_symbol = sqrt(transmit_power)*modulated_symbol;
noise = sqrt(1/2)* (randn(1, length(modulated_symbol)) +1j*randn(1, length(modulated_symbol)) );


% fading channel
transmission_symbol = transmission_symbol.*h;


%% receive
% equalizer
received_symbol = (transmission_symbol + noise) ./h;

recovered_bit_data = QPSK_Demapper(received_symbol);

if flag
    recovered_bit_data(end) = []; %전체 글자수가 홀수 였으면 맨 뒤 요소 삭제
    nSymbols = nSymbols - 1; %전체 비트수 변경
end


%% 다시 문자로 바꾸기
recovered_data = reshape(recovered_bit_data, 7, []);
recovered_data = recovered_data';


decimalValues = bin2dec(num2str(recovered_data));

% ASCII 코드를 문자로 변환
textString = char(decimalValues)';









%% function

% 파일 불러오기
function binaryNumArray = readFile(filename)
    fileID = fopen(filename, 'r');
    textString = fread(fileID, '*char')'; % 전체 파일 내용을 문자열로 읽기
    fclose(fileID);

    disp(textString);
    
    % 문자열의 각 문자를 ASCII 코드 값으로 변환
    asciiValues = double(textString);
    
    % ASCII 코드 값을 2진수로 변환
    binaryStrings = dec2bin(asciiValues, 8);
    
    
    % 문자 배열을 숫자 배열로 변환
    binaryNumArray = binaryStrings - '0';
    
    % n X m 배열을 1xm*n 배열로 변환
    binaryNumArray = reshape(binaryNumArray', 1, []);


end


% 이진 숫자 배열을 문자열로 변환하는 함수
function strData = binaryArrayToString(binaryArray)
    % 이진 배열을 문자열로 변환
    binaryStrings = reshape(char(binaryArray + '0'), 8, []).';
    strData = '';
    for i = 1:size(binaryStrings, 1)
        strData = [strData char(bin2dec(binaryStrings(i, :)))];
    end
end

% DES3 암호화를 수행하는 함수
function enc_data = DES3(msg, keytext, ivtext)
    % 이진 배열을 문자열로 변환
    strMsg = binaryArrayToString(msg);
    disp(strMsg)

    % 파이썬 스크립트 호출
    command = sprintf('python C:\Users\User\OneDrive - 한밭대학교\문서\MATLAB\TEST\des_enc.py "%s" "%s" "%s"', strMsg, keytext, ivtext);
    [status, enc_data] = system(command);

    if status ~= 0
        error('Error in DES3 encryption');
    end
end


%% function zip
%QPSK 맵핑 함수
function [QPSK_Symbol] =  QPSK_Mapper(Data)
    
    N = length(Data); % 길이

    QPSK_Symbol = zeros(1, N/2);
    for i= 1:N/2
        two_bit = [Data(2*i-1) Data(2*i)];
        % disp(two_bit)
    
        if two_bit == [0 0]
            QPSK_Symbol(i) = sqrt(1/2) + sqrt(1/2)*j;
    
        elseif two_bit == [0 1]
            QPSK_Symbol(i) = -sqrt(1/2) + sqrt(1/2)*j;
    
        elseif two_bit == [1 1]
            QPSK_Symbol(i) = -sqrt(1/2) -sqrt(1/2)*j;
    
        else
            QPSK_Symbol(i) = sqrt(1/2) -sqrt(1/2)*j;
    
        end
    end

end

%QPSK 디맵핑 함수
function [x_hat] = QPSK_Demapper(r)
    L = length(r);
    x_hat = zeros(1, 2*L);

    for n = 1:L
        if real(r(n)) >=0 && imag(r(n)) >= 0
            x_hat(2*(n-1)+1:2*n) = [0 0];
        elseif real(r(n)) <0 && imag(r(n)) >= 0
            x_hat(2*(n-1)+1:2*n) = [0 1];
        elseif real(r(n)) <0 && imag(r(n)) < 0
            x_hat(2*(n-1)+1:2*n) = [1 1];
        else
             x_hat(2*(n-1)+1:2*n) = [1 0];
        end

    end
    % disp(x_hat)
end

