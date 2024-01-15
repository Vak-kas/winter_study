clear variables;
clc;


%% Setting var
SNR_dB = 1:1:20;
nSymbol = 100000;
M = 4;  %2 = BPSK, 4 = QPSK, 8 = 8-PSK, 16 = 16QAM
%bitstream = [0, 1, 0, 0, 1, 1, 1, 0];

fad = true;      % true시 fading channel, false시 awgn채널
adapt_eq = true;  % true시 eqaulization 적용, false 시 미적용



%% Preparation(DATA)
BER = zeros(1, length(SNR_dB));

for i = 1:1:length(SNR_dB)
    bit_data = randi([0, 1], 1, nSymbol );
    
    %% 변조
    modulated_symbol = QPSK_Mapper(bit_data);
    
    %% Transmission System
    %r(n) = h(n) * y(n) + z(n)
    SNR_linear = 10^(SNR_dB(i)/10); %Signal Power
    transmit_power = SNR_linear; % 출력세기 (y(n))
    h = sqrt(1/2)*(randn(1, length(modulated_symbol)) + 1j*randn(1, length(modulated_symbol)) ); %무선 채널의 개수(h(n))
    transmission_symbol = sqrt(transmit_power)*modulated_symbol;
    noise = sqrt(1/2)*(randn(1, nSymbol/log2(M)) +1j*randn(1, nSymbol/log2(M)) );
    
    %fad= true 일 경우에는 fading channel 을 지나는 것이고, 
    % fad = false 일 경우 AWGN 채널을 지나는 것으로 설정
    
    if fad == true
        transmission_symbol = transmission_symbol.*h;
    end
    
    %% Equalizer
    before_equlizer = transmission_symbol + noise;
    if adapt_eq == false
        received_symbol = before_equlizer;
    else
        received_symbol = before_equlizer./h;
    end
    %% Receiver - Demodulation 
    if i==10
        figure(11);
        plot(real(modulated_symbol), imag(modulated_symbol), "b*");
        xlabel("in-Phase");
        ylabel("Quadrature");
        grid on;
        plot(real(received_symbol)/sqrt(transmit_power), imag(received_symbol)/sqrt(transmit_power), "ro");
        xlim([-3, 3]); ylim([-3, 3]);
    end

    
    %%
    received_bit_data = QPSK_Demapper(received_symbol);
    BER(i) = sum(bit_data ~= received_bit_data) / nSymbol;
end

%% Ploting BER Curve
figure(2);
if fad == true
    semilogy(SNR_dB, BER, "b-"); grid on;
else
    semilogy(SNR_dB, BER, "r-"); grid on;
end

ylim([10^-5 1]); xlim([1 20]);
ylabel("BER");
xlabel("SNR(dB)");
hold on;


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


















