clear variables
clc

%% 기본 셋팅
SNR_dB = 100;
nSymbol = 100000;
SNR_linear = 10^(SNR_dB/10); %Signal Power
M = 2 ; %BPSK 로 실험
 
alpha = 1.2; % h의 값의 범위에 따라 판단하는 알파
epsilon = 0.1; % 채널 추정 오류


%% 실험 준비
bit_data = ones(1, nSymbol); %비트 데이터 생성



h = sqrt(1/2)*(randn(1, length(bit_data)) + 1j*randn(1, length(bit_data)) ); %무선 채널의 개수(h(n))
noise1 = sqrt(1/2)*(randn(1, length(bit_data)) + 1j*randn(1, length(bit_data)) ); %송신측에서 추정할 때 나오는 노이즈
noise2 = sqrt(1/2)*(randn(1, length(bit_data)) + 1j*randn(1, length(bit_data)) ); % 수신측에서 추정할 때 나오는 노이즈


h1 = h + epsilon*noise1; %송신측에서 예측하는 h
h2 = h + epsilon*noise2; %수신측에서 예측하는 h


% A측에서 무선채널을 보고 생성한 key값
key1 = zeros(1, nSymbol); 
key1(abs(h1).^2>alpha) = 1 ;


% B측에서 무선채널을 보고 생성한 key값
key2= zeros(1, nSymbol);
key2(abs(h2).^2>alpha) = 1;



encode_bit_data = xor(key1, bit_data); %암호화 하기
modulated_symbol = BPSK_Mapper(encode_bit_data);






%% Transmission System
transmit_power = SNR_linear; % 출력세기 (y(n))
transmission_symbol = sqrt(transmit_power)*modulated_symbol.*h + noise2; %수신측에서 전송받은 심볼


%% Receiver - Demodulation (BPSK)
received_symbol = transmission_symbol./h; %equalizer

recovered_data = BPSK_Demapper(received_symbol); %BPSK 로 디맵핑


recovered_bit_data = xor(key2, recovered_data); %키 값으로 복호화


BER = sum(recovered_bit_data ~= bit_data)/nSymbol; %원본 데이터와 받은 데이터 오류율 확인
KER = sum(key1~=key2)/nSymbol;


%% 결과 값 출력

disp("채널 성능 오류");
disp(epsilon);
disp("BER");
disp(BER);
disp("키 오류율");
disp(KER);

%% 도청자
hh = sqrt(1/2)*(randn(1, length(bit_data)) + 1j*randn(1, length(bit_data)) );
noise3 = sqrt(1/2)*(randn(1, length(bit_data)) + 1j*randn(1, length(bit_data)) );
h3 = hh + epsilon*noise3;
key3= zeros(1, nSymbol);
key3(abs(h3).^2>alpha) = 1;
dec_bit_data = xor(key3, encode_bit_data); %키 값으로 복호화

disp("도청자에서의 BER");
disp(sum(dec_bit_data~= bit_data)/nSymbol);
%% function

% BPSK_Mapping
function [modulated_symbol] = BPSK_Mapper(data)
    modulated_symbol = zeros(1, length(data));

    modulated_symbol(data==1) = (1+1j)/sqrt(2);
    modulated_symbol(data==0) = (-1-1j)/sqrt(2);
end

% BPSK_DeMapping
function [recovered_data] = BPSK_Demapper(received_symbol)
    recovered_data = zeros(1, length(received_symbol));

    recovered_data(real(received_symbol) + imag(received_symbol) > 0) = 1;
    recovered_data(real(received_symbol) + imag(received_symbol) < 0) = 0;
end




