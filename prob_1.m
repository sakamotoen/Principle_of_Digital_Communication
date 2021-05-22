clc
close all
clear all
SNR=0:1:20;                 %信噪比变化范围
SNR1=0.5*(10.^(SNR/10));    %将信噪比转化成直角坐标
N=1000000;                  %仿真点数
X=4;                        %进制数
x=randi([0,1],1,N);         %产生随机信号
h=pskmod(x,X);              %调用matlab自带的psk调制函数
for i=1:length(SNR);
    yAn=awgn(h,SNR(i),'measured'); 
    yA=pskdemod(yAn,X);     %QPSK属于4PSK
    [bit_A,l]=biterr(x,yA); 
    QPSK_s_AWGN(i)=bit_A/N;
end
QPSK_t_AWGN=1/2*erfc(sqrt(10.^(SNR/10)/2));   %AWGN信道下QPSK理论误码率

%绘制图形
figure
semilogy(SNR,QPSK_s_AWGN,'r');hold on;
semilogy(SNR,QPSK_t_AWGN,'y');hold on;
grid on;
axis([-1 20 10^-4 1]);
legend('AWGN仿真','AWGN理论');
title('QPSK误码性能分析');
xlabel('SNR（dB）');ylabel('BER');

