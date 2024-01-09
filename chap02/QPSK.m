clear variables;
clc;
%% Preparation(DATA)
N = 100000; % 생성할 데이터 bit 수
M = 4;
bit_data= randi([0, 1], 1, N); % bit_stream [0 0 1 1 0 0...]
SNR_dB = 1:1:10;
BER = zeros(1, length(SNR_dB));
for i  = 1:1:length(SNR_dB)
    %% 변조
    modulated_symbol = QPSK_Mapper(bit_data);
    
    % 그리기
    figure(1);
    plot(real(modulated_symbol), imag(modulated_symbol), "b*");
    xlim([-2, 2]); ylim([-2, 2]);
    xlabel("in-Phase");
    ylabel("Quadrature");
    grid on;
    
    %% Transmission System
    %r(n) = y(n) + z(n)
    r = AWGN(modulated_symbol, SNR_dB(i));
    % r = modulated_symbol; % noise 가 끼지 않았을 때
    
    
    %받은 거 그리기
    if i==10
        figure(1);
        hold on;
        plot(real(r), imag(r), "ro");
    end
    
    
    %% 복조
    received_bit_data = QPSK_Demapper(r);


    BER(i) = sum(bit_data ~= received_bit_data) / N;

end

%% Ploting BER Curve
figure(2);
semilogy(SNR_dB, BER, "b-"); grid on;
ylim([10^-5 1]); xlim([1 10]);
ylabel("BER");
xlabel("SNR(dB)");




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

% AWGN 
function [r] = AWGN(y, SNR_dB)
    %r(n) = y(n) + z(n)
    SNR_linear = 10.^(-SNR_dB/10); %Signal Power
    transmit_power = SNR_linear;
    z = sqrt(1/2*transmit_power)*(randn(1, length(y)) +1j*randn(1, length(y)) );
    r = y+z;
end
