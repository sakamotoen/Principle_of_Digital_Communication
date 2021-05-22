%假设信道为 g(t)=delta(t-0.5 Ts)+delta(t-3.5 Ts)
clc;
clear all;
close all;
%设BPSK调制信号为:+1/-1
X=zeros(64,64);
d=rand(64,1);
      for i=1:64
       if(d(i)>=0.5)
           d(i)=+1;
       else
           d(i)=-1;
       end
    end
 for i=1:64
     X(i,i)=d(i);
 end
%计算G[信道矩阵]
  tau=[0.5 3.5];%间距
%生成矩阵G...
for k=1:64
      s=0;
      for m=1:2
         s=s+(exp(-j*pi*(1/64)*(k+63*tau(m))) * (( sin(pi*tau(m)) / sin(pi*(1/64)*(tau(m)-k)))));
      end
g(k)=s/sqrt(64);
end
G=g';
r=raylrnd(0.5,1,64);         %产生瑞丽信号
G = G * r;                   %模拟瑞利信道
H=fft(G);% 计算频域

XFG=X*H;
n1=ones(64,1);
n1=n1*0.000000000000000001i;%确保每个点添加了高斯噪声
noise=awgn(n1,8);
variance=var(noise);
N=fft(noise);
Y=XFG+N;
%% G-Rgg自协方差矩阵的估计
gg=zeros(64,64);
for i=1:64
    gg(i,i)=G(i);
end
gg_myu = sum(gg, 1)/64;                    
gg_mid = gg - gg_myu(ones(64,1),:);        
sum_gg_mid= sum(gg_mid, 1);
Rgg = (gg_mid' * gg_mid- (sum_gg_mid'  * sum_gg_mid) / 64) / (64 - 1);

%% LS参数估计
%参数Hls、Hls = inv(X)*Y
H_ls=(inv(X)) * Y;
Hls=zeros(64,64);
for i=1:64
    Hls(i,i)=H_ls(i);
end
%仿真
for n=1:6

SNR_send=5*n;
error_count_ls=0;

%传输1000个数据比特
for c=1:1000
%生成随机数矩阵
X=zeros(64,64);
d=rand(64,1);
      for i=1:64
       if(d(i)>=0.5)
           d(i)=+1;
       else
           d(i)=-1;
       end
    end
 for i=1:64
     X(i,i)=d(i);
 end
XFG=X*H;%通过信道
n1=ones(64,1);
n1=n1*0.000000000000000001i;
noise=awgn(n1,SNR_send);
variance=var(noise);
N=fft(noise);
Y=XFG+N;%接收到信号与噪声
% I:LS 信道估计Rx
    %I(k) 表示决策矩阵
    I=inv(Hls)* Y;
     for k=1:64
       
        if(real(I(k))>0)
            I(k)=1;
         else
            I(k)=-1;
         end
     end 
   for k=1:64
        if(I(k)~=d(k))
            error_count_ls=error_count_ls+1;
        end
   end
end%结束1000次信号比特传输

ser_ls(n)=error_count_ls/64000;
ser_ls
SNR(n)=SNR_send;

end;

hold on;
semilogy(SNR,ser_ls,'b*');
semilogy(SNR,ser_ls,'b-');
grid on;
xlabel('SNR in DB');
ylabel('Symbol Error Rate');
title('LS信道估计的接收机误码性能分析');
