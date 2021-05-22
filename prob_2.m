clc
close all
clear all
SNR=0:1:20;                 %信噪比变化范围
SNR1=0.5*(10.^(SNR/10));    %将信噪比转化成直角坐标
N=1000000;                  %仿真点数
X=4;                        %进制数
x=randi([0,1],1,N);         %产生随机信号
R=raylrnd(0.5,1,N);         %产生瑞丽信号
h=pskmod(x,X);              %调用matlab自带的psk调制函数
hR=h.*R;
%scatterplot(hR)
for i=1:length(SNR);  
    yRn=awgn(hR,SNR(i),'measured');
    yR=pskdemod(yRn,X);     %调用matlab自带的psk解调函数
    [bit_R,ll]=biterr(x,yR);
    QPSK_s_Ray(i)=bit_R/N; 
end
QPSK_t_Ray= -(1/4)*(1-sqrt(SNR1./(SNR1+1))).^2+(1-sqrt(SNR1./(SNR1+1)));
%Rayleigh信道下QPSK理论误码率

%绘制图形
figure
semilogy(SNR,QPSK_s_Ray,':b*');hold on
semilogy(SNR,QPSK_t_Ray,':go'); grid on;
axis([-1 20 10^-4 1]);
legend('瑞利仿真','瑞利理论');
title('QPSK误码性能分析');
xlabel('信噪比（dB）');ylabel('BER');