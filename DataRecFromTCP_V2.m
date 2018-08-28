function []=DataRecFromTCP_V2()
%% Step1. 初始化TCP/IP连接
%clear;
tcp_Server = tcpip('192.168.1.151',8123,'NetWorkRole','Server'); %需要调整第二个参数——端口号
set(tcp_Server,'Timeout',300); %设置连接超时
set(tcp_Server,'InputBufferSize',4096*30); %设置接收缓存
fopen(tcp_Server); %启动sever，等待无线设备连入
comd=input('input a commend:');
if comd==0
fwrite(tcp_Server,[165 90 00 255 15],'uint8'); %向无线设备发送，启动数据传输
elseif comd==1
fwrite(tcp_Server,[165 90 01 255 15],'uint8'); %向无线设备发送，启动阻抗测试
else
fwrite(tcp_Server,[165 90 02 255 15],'uint8'); %向无线设备发送，暂停数据传输
end
% Setup a figure window and define a callback function for close operation
figureHandle = figure('NumberTitle','off',...
    'Name','EEG',...
    'CloseRequestFcn',{@localCloseFigure,tcp_Server});
%%tic
%% Step2. 接收数据
while comd ~=2
EegChData = zeros(8,1000); % 数据
biterror = zeros(1,1000); % 错误标识位
for t = 1:1000 %——————注意这里需要修改循环的次数，或者用while循环
   tic   
    nb_Bytes = get(tcp_Server,'BytesAvailable');%侦听TCP接口，如果没有数据就返回0
    
    biterrorflag=0; % 数据接收无差错
    while nb_Bytes==0
        nb_Bytes = get(tcp_Server,'BytesAvailable');%侦听TCP接口，如果没有数据就返回0
    end
        nb_Bytes = 30; %每次读取的字符数
        recvRaw = fread(tcp_Server,nb_Bytes,'uint8');
        %% Step3. 将接收到数据进行转码
        if length(recvRaw) == 30 && recvRaw(1) == 165 && recvRaw(2) == 90 && recvRaw(29) == 255 && recvRaw(30) == 15 %如果接收到的数据帧头是 A5 5A(16进制) 帧尾
            recvData = zeros(1,8*1);
            %ChalImp = zeros(8,1);
            DevID=recvRaw(3);       %设备ID  
            QuaCharge=recvRaw(28);  %设备电量，百分制    
            for i = 1:8 %使用反码机制处理接收到的数据
                a = bitshift(recvRaw(4+(i-1)*3),16) + bitshift(recvRaw(5+(i-1)*3),8) + recvRaw(6+(i-1)*3);
                if bitand(a,8388608) %十六进制的800000
                    if a == 8388608
                        y = -8388607;%0x7fffff
                    else
                        % 取反后加1
                       % y = -1*(bitcmp(a,24)+1);
                        y= -1*(bitxor(a,16777215)+1);
                    end
                else
                    y = a;
                
                end 
                
                recvData(1,i) = y/24*4500/8388607;  % 电压值，单位mV
                
                
            end
            %输出数据，格式为 8*1，通道数*采样点数
            if comd==0
            mx_ContinuousData = reshape(recvData,8,1) ;        %电压值 单位 mV
           
            EegChData(1,t)= recvData(1,1); %保存第一个通道的数值，如果保存其他通道，则EegChData(x,t)= recvData(1,x)
            EegChData(2,t)= recvData(1,2); %保存第2个通道的数值，
             EegChData(3,t)= recvData(1,3); %保存第3个通道的数值，
              EegChData(4,t)= recvData(1,4); %保存第4个通道的数值，
               EegChData(5,t)= recvData(1,5); %保存第5个通道的数值，
                EegChData(6,t)= recvData(1,6); %保存第6个通道的数值，
                 EegChData(7,t)= recvData(1,7); %保存第7个通道的数值，
                  EegChData(8,t)= recvData(1,8); %保存第8个通道的数值，
            else
                ChalImp= reshape(20.9142*recvData-9.3071,8,1)  ;  %阻抗测试，在阻抗测试命令下可用，单位KΩ
            end
        else
            biterrorflag=1; % 帧错误
            comd=2;
        end
    
          %biterrorflag=2; %数据未收到
    %end
   biterror(1,t) = biterrorflag;
   toc
end


 save eegdata EegChData;
 save  BitError biterror;
 drawnow;
 %toc
 %tic
 % DevID      %设备ID

 %hold on;
 
end
%% Step4.销毁资源
%% Implement the close figure callback
function localCloseFigure(figureHandle,~,tcp_Server)
%% 销毁资源
comd=2;
delete(figureHandle);
fwrite(tcp_Server,[165 90 02 255 15],'uint8'); %向无线设备发送，暂停数据传输
fclose(tcp_Server);
delete(tcp_Server);
% Close the figure window

%fclose(tcp_Server);
%delete(tcp_Server);