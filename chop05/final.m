clear variables;
clc;

%% Setting var (기본 세팅)
SNR_dB =20; %SNR 값
SNR_linear = 10^(SNR_dB/10); %Signal Power
M = 4; % 기본적인 이 실험은 QPSK로 만 진행할 예정
block_size = 128; %AES128, 192 , 256 
repeat_time =1; %FEC 에서 반복횟수



%% 실험 준비
block_size = block_size/4;
key = RandomKey(block_size); % 키 값 생성. 16진수는 4개에 1바이트이기에 4로 나눠서 32길이의 키 생성  




plaintext= readFile("./plain.txt"); % 파일의 내용 불러오기
original_bit_data = origin_binary_array(plaintext); %원본 


%% 암호화 
tmp = hex_array(plaintext, block_size);
enc_data = cell(1, length(tmp)/block_size); % 암호화한 것을 저장한 변수
idx = 1;
for i = 1:block_size:length(tmp) % 처음 설정한 block_size 비트 만큼 끊어서 암호화
    hexChunk = tmp(i:i+block_size-1);
    a = Cipher(key, hexChunk);
    enc_data{idx} = a;
    idx = idx+1;
end
enc_data =  cell2mat(enc_data);
bit_data = hex_to_binary(enc_data) -'0';

%% 암호화를 블록단위로 하지 않고 한 번에 할 경우
% enc_data = Cipher(key, hex_array(plaintext, block_size));
% bit_data = hex_to_binary(enc_data) - '0';


%% 변조
if M==2
elseif M == 4
    fec_bit_data = REP_FEC(bit_data, repeat_time);
    modulated_symbol = QPSK_Mapper(fec_bit_data);  %QPSK 맵핑
elseif M == 16   
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

recovered_fec_bit_data = QPSK_Demapper(received_symbol);


%% FEC
recovered_bit_data = FEC_check(recovered_fec_bit_data, repeat_time); %fec 로 비트 확인
hexData = binary_to_hex(recovered_bit_data); % 16진수 데이터 예시

% double 형식의 이진 데이터를 문자열로 변환
% disp(enc_data);
% disp(hexData);

%% 복호화
key2 = RandomKey(block_size);
dec_data = cell(1, length(hexData)/block_size); % 암호화한 것을 저장한 변수
idx = 1;
for i = 1:block_size:length(hexData)
    hexChunk = hexData(i:i+block_size-1);
    a = InvCipher(key, hexChunk);
    dec_data{idx} = a;
    idx = idx+1;
end
dec_data =  cell2mat(dec_data);

%% 복호화를 블록단위가 아닌 한 번에 할 경우
% key2 = RandomKey(block_size);
% dec_data = InvCipher(key2, hexData);



%% 문자열 변환

%패딩 삭제
l1 = length(plaintext);
recovered_plaintext = char(hex_to_dec(dec_data));
l2 = length(recovered_plaintext);
l = l2-l1;


%출력
disp(recovered_plaintext(1:end-l));






%% function zip
% 키 생성하기
function key = RandomKey(key_length)
    randBytes = randi([0, 255], 1, key_length, 'uint8'); % 0부터 255 사이의 랜덤 정수 생성
    % disp(randBytes);
    hexString = dec2hex(randBytes, 2); % 16진수 문자열로 변환 (2자리로 표현)
    % disp(hexString);
    key = reshape(hexString, 1, []);
end

% 파일 불러오기
function textString = readFile(filename)
    fileID = fopen(filename, 'r'); %파일 열기
    textString = fread(fileID, '*char')'; % 전체 파일 내용을 문자열로 읽기
    fclose(fileID); %파일 닫기
end

% 패딩 추가하기
function padding_plaintext = addPadding(plaintext, block_size)
    pad_length = block_size - mod(length(plaintext), block_size);
    padding = repmat('0', 1, pad_length);
    padding_plaintext = [plaintext padding];
end

% 2진 데이터로 바꾸기
function binaryNumArrays = origin_binary_array(plaintext)
    asciiValues = double(plaintext); % 문자열의 각 문자를 ASCII 코드 값으로 변환
    binaryStrings = dec2bin(asciiValues, 8); % ASCII 코드 값을 2진수로 변환
    binaryNumArray = binaryStrings - '0'; % 숫자로 변형
    binaryNumArrays = reshape(binaryNumArray', 1, []); % 1차원 배열로 모양 바꾸기
end

%패딩 추가 후 16진 데이터로 바꾸기
function hex_string = hex_array(plaintext, block_size)
    p_plaintext = addPadding(plaintext, block_size); %패딩 추가하기
    hex_value = unicode2native(p_plaintext); % 문자열을 10진수 숫자 배열로 변환
    % 16진수로 표현된 숫자 배열을 16진수 문자열로 변환
    hex_string = dec2hex(hex_value, 2); % 각 숫자를 2자리 16진수로 표현
    hex_string = reshape(hex_string', 1, []);
end


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
%% fec
function [Repeat_bit_data]  = REP_FEC(bit_data, Repeat_time)
    Repeat_bit_data = repmat(bit_data, 1, Repeat_time);
end

function [bit_data] = FEC_check(Repeat_bit_data, Repeat_time)
    bit_data = zeros(1, length(Repeat_bit_data)/Repeat_time);
    nSymbol = length(bit_data);
    for i = 1:nSymbol
        s = 0;
        for j  = 1:Repeat_time
            s = s + Repeat_bit_data(nSymbol*(j-1)+i);    
        end
        bit_data(i) = round((s/Repeat_time));
    end

end
%% 진수 변환
% 16진수를 10진수로 변환
function result = hex_to_dec(hexString)
    result = ''; % 결과를 저장할 변수 초기화
    
    % 16진수 문자열을 2자리씩 나누어 처리
    for i = 1:2:length(hexString)
        % 현재 위치에서 2자리를 추출
        hexChunk = hexString(i:i+1);
        
        % 16진수를 10진수로 변환
        decimalValue = hex2dec(hexChunk);
        
        % 10진수를 ASCII 문자로 변환하여 결과에 추가
        result = [result char(decimalValue)];
    end
end

%16진수를 2진수로 변환
function binaryValue =hex_to_binary(hexValue)
    hexDigits = '0123456789ABCDEF'; % 16진수 자릿수에 해당하는 문자열
    binaryValue = '';
    for i = 1:length(hexValue)
        digit = hexValue(i);
        % 각 16진수 자릿수를 4비트 2진수로 변환
        binaryDigit = dec2bin(hex2dec(digit), 4);
        binaryValue = [binaryValue binaryDigit];
    end

end

% 2진수를 16진수로 만들기
function hexString = binary_to_hex(binaryData)
    % 이진수 문자열을 4자리씩 끊어서 16진수로 변환
    binaryText = num2str(binaryData); 
    binaryText = strrep(binaryText, ' ', '');
    % 4비트씩 끊어서 16진수로 변환
    hexString = '';
    for i = 1:4:length(binaryText)
        binaryChunk = binaryText(i:i+3); % 4비트씩 자름
        decimalValue = bin2dec(binaryChunk); % 10진수로 변환
        hexDigit = dec2hex(decimalValue); % 16진수로 변환
        hexString = [hexString hexDigit]; % 결과 문자열에 추가
    end
   
end




%% 암호화 함수들
function Out = Cipher(key,In)
    %AES-128,192,256 cipher
    %Impliments FIBS-197, key is a 128, 292, or 256-bit hexidecimal input, 
    %message (In) is 128-bit hexidecimal. Application does not check lengths of
    %keys or message input but will error if they are not of the correct
    %length.
    %David Hill
    %Version 1.0.4 32 48 64
    %1-25-2021
    Nk=length(key)/8;
    In=hex2dec(reshape(In,2,[])');%converts hex bytes into decimal
    w=KeyExpansion(key,Nk);%key expansion per standard
    state=reshape(In,4,[]);%reshapes input into state matrix
    state=AddRoundKey(state,w(:,1:4));%conducts first round
    for k=2:(Nk+6)%conducts follow-on rounds
        state=SubBytes(state);%per standard
        state=ShiftRows(state);%per standard
        state=MixColumns(state);%per standard
        state=AddRoundKey(state,w(:,4*(k-1)+1:4*k));%per standard
    end
    state=SubBytes(state);
    state=ShiftRows(state);
    state=AddRoundKey(state,w(:,4*(Nk+6)+1:4*(Nk+7)));
    Out=state(:);%changes output to column vector
    Out=lower(dec2hex(Out(1:length(In)))');%converts output to hex
    Out=Out(:)';%converts output to row vector
    end
    
    function state = AddRoundKey(state,w)
        for k=1:4
            state(:,k)=bitxor(state(:,k),w(:,k));
        end
end




function State = MixColumns(state)
    State=state;
    for a=1:4:13
        State(a)=bitxor(bitxor(bitxor(xtime(state(a),2),xtime(state(a+1),3)),state(a+2)),state(a+3));
        State(a+1)=bitxor(bitxor(bitxor(xtime(state(a+1),2),xtime(state(a+2),3)),state(a)),state(a+3));
        State(a+2)=bitxor(bitxor(bitxor(xtime(state(a+2),2),xtime(state(a+3),3)),state(a)),state(a+1));
        State(a+3)=bitxor(bitxor(bitxor(xtime(state(a+3),2),xtime(state(a),3)),state(a+1)),state(a+2));
    end
end



function state = ShiftRows(state)
    state(2,:)=circshift(state(2,:),[0 -1]);
    state(3,:)=circshift(state(3,:),[0 -2]);
    state(4,:)=circshift(state(4,:),[0 -3]);
end


function state = SubBytes(state)
    Sbox=['637c777bf26b6fc53001672bfed7ab76';...
          'ca82c97dfa5947f0add4a2af9ca472c0';...
          'b7fd9326363ff7cc34a5e5f171d83115';...
          '04c723c31896059a071280e2eb27b275';...
          '09832c1a1b6e5aa0523bd6b329e32f84';...
          '53d100ed20fcb15b6acbbe394a4c58cf';...
          'd0efaafb434d338545f9027f503c9fa8';...
          '51a3408f929d38f5bcb6da2110fff3d2';...
          'cd0c13ec5f974417c4a77e3d645d1973';...
          '60814fdc222a908846eeb814de5e0bdb';...
          'e0323a0a4906245cc2d3ac629195e479';...
          'e7c8376d8dd54ea96c56f4ea657aae08';...
          'ba78252e1ca6b4c6e8dd741f4bbd8b8a';...
          '703eb5664803f60e613557b986c11d9e';...
          'e1f8981169d98e949b1e87e9ce5528df';...
          '8ca1890dbfe6426841992d0fb054bb16'];
    Sbox=reshape(hex2dec(reshape(Sbox',2,[])'),16,16);
    state=Sbox(state+1);
end


function a = xtime(x,c)
    a=0;
    if bitget(x,1)
        a=c;
    end
    x=bitshift(x,-1);
    while x>0
        c=bitshift(c,1);
        if bitget(c,9)
            c=bitset(c,9,0);
            c=bitxor(c,27);
        end
        if bitget(x,1)
            a=bitxor(a,c);
        end
        x=bitshift(x,-1);
    end
end    

function w = KeyExpansion(key,Nk)
    key=hex2dec(reshape(key,2,[])');
    w=reshape(key,4,[]);
    for i=Nk:4*(Nk+7)-1
        temp=w(:,i);
        if mod(i,Nk)==0
            temp=SubBytes(circshift(temp,-1));
            n=1;
            m=0;
            while m<i/Nk-1%needed to modulate higher powers of 2 per standard
                n=xtime(2,n);
                m=m+1;
            end
            temp=bitxor(temp,[n,0,0,0]');
        elseif Nk>6 && mod(i,8)==4
            temp=SubBytes(temp);
        end
        w(:,i+1)=bitxor(w(:,i-Nk+1),temp);
    end
end

%% 복호화 함수들
function Out = InvCipher(key,In)
    %AES-128,192,or 256 inverse cipher
    %Impliments FIBS-197, key is 128, 192, or 256-bit hexidecimal input, 
    %message (In) is 128-bit hexidecimal. Application does not check lengths of
    %keys or message input but will error if they are not of the correct
    %length.
    %David Hill
    %Version 1.0.4
    %1-25-2021
    Nk=length(key)/8;
    In=hex2dec(reshape(In,2,[])');
    w=KeyExpansion(key,Nk);
    state=reshape(In,4,[]);
    state=AddRoundKey(state,w(:,4*(Nk+6)+1:4*(Nk+7)));
    for k=(Nk+6):-1:2
        state=InvShiftRows(state);
        state=InvSubBytes(state);
        state=AddRoundKey(state,w(:,4*(k-1)+1:4*k));
        state=InvMixColumns(state);
    end
    state=InvShiftRows(state);
    state=InvSubBytes(state);
    state=AddRoundKey(state,w(:,1:4));
    Out=state(:)';
    Out=lower(dec2hex(Out(1:length(In)))');
    Out=Out(:)';
end

function State = InvMixColumns(state)
    State=state;
    for a=1:4:13
        State(a)=bitxor(bitxor(bitxor(xtime(state(a),14),xtime(state(a+1),11)),xtime(state(a+2),13)),xtime(state(a+3),9));
        State(a+1)=bitxor(bitxor(bitxor(xtime(state(a),9),xtime(state(a+1),14)),xtime(state(a+2),11)),xtime(state(a+3),13));
        State(a+2)=bitxor(bitxor(bitxor(xtime(state(a),13),xtime(state(a+1),9)),xtime(state(a+2),14)),xtime(state(a+3),11));
        State(a+3)=bitxor(bitxor(bitxor(xtime(state(a),11),xtime(state(a+1),13)),xtime(state(a+2),9)),xtime(state(a+3),14));
    end
end

function state = InvShiftRows(state)
    state(2,:)=circshift(state(2,:),[0 1]);
    state(3,:)=circshift(state(3,:),[0 2]);
    state(4,:)=circshift(state(4,:),[0 3]);
end


function state = InvSubBytes(state)
    Sbox=['52096ad53036a538bf40a39e81f3d7fb';...
          '7ce339829b2fff87348e4344c4dee9cb';...
          '547b9432a6c2233dee4c950b42fac34e';...
          '082ea16628d924b2765ba2496d8bd125';...
          '72f8f66486689816d4a45ccc5d65b692';...
          '6c704850fdedb9da5e154657a78d9d84';...
          '90d8ab008cbcd30af7e45805b8b34506';...
          'd02c1e8fca3f0f02c1afbd0301138a6b';...
          '3a9111414f67dcea97f2cfcef0b4e673';...
          '96ac7422e7ad3585e2f937e81c75df6e';...
          '47f11a711d29c5896fb7620eaa18be1b';...
          'fc563e4bc6d279209adbc0fe78cd5af4';...
          '1fdda8338807c731b11210592780ec5f';...
          '60517fa919b54a0d2de57a9f93c99cef';...
          'a0e03b4dae2af5b0c8ebbb3c83539961';...
          '172b047eba77d626e169146355210c7d'];
    Sbox=reshape(hex2dec(reshape(Sbox',2,[])'),16,16); 
    state=Sbox(state+1);
end
