function []=DataRecFromTCP_V2()
%% Step1. ��ʼ��TCP/IP����
%clear;
tcp_Server = tcpip('192.168.1.151',8123,'NetWorkRole','Server'); %��Ҫ�����ڶ������������˿ں�
set(tcp_Server,'Timeout',300); %�������ӳ�ʱ
set(tcp_Server,'InputBufferSize',4096*30); %���ý��ջ���
fopen(tcp_Server); %����sever���ȴ������豸����
comd=input('input a commend:');
if comd==0
fwrite(tcp_Server,[165 90 00 255 15],'uint8'); %�������豸���ͣ��������ݴ���
elseif comd==1
fwrite(tcp_Server,[165 90 01 255 15],'uint8'); %�������豸���ͣ������迹����
else
fwrite(tcp_Server,[165 90 02 255 15],'uint8'); %�������豸���ͣ���ͣ���ݴ���
end
% Setup a figure window and define a callback function for close operation
figureHandle = figure('NumberTitle','off',...
    'Name','EEG',...
    'CloseRequestFcn',{@localCloseFigure,tcp_Server});
%%tic
%% Step2. ��������
while comd ~=2
EegChData = zeros(8,1000); % ����
biterror = zeros(1,1000); % �����ʶλ
for t = 1:1000 %������������ע��������Ҫ�޸�ѭ���Ĵ�����������whileѭ��
   tic   
    nb_Bytes = get(tcp_Server,'BytesAvailable');%����TCP�ӿڣ����û�����ݾͷ���0
    
    biterrorflag=0; % ���ݽ����޲��
    while nb_Bytes==0
        nb_Bytes = get(tcp_Server,'BytesAvailable');%����TCP�ӿڣ����û�����ݾͷ���0
    end
        nb_Bytes = 30; %ÿ�ζ�ȡ���ַ���
        recvRaw = fread(tcp_Server,nb_Bytes,'uint8');
        %% Step3. �����յ����ݽ���ת��
        if length(recvRaw) == 30 && recvRaw(1) == 165 && recvRaw(2) == 90 && recvRaw(29) == 255 && recvRaw(30) == 15 %������յ�������֡ͷ�� A5 5A(16����) ֡β
            recvData = zeros(1,8*1);
            %ChalImp = zeros(8,1);
            DevID=recvRaw(3);       %�豸ID  
            QuaCharge=recvRaw(28);  %�豸�������ٷ���    
            for i = 1:8 %ʹ�÷�����ƴ�����յ�������
                a = bitshift(recvRaw(4+(i-1)*3),16) + bitshift(recvRaw(5+(i-1)*3),8) + recvRaw(6+(i-1)*3);
                if bitand(a,8388608) %ʮ�����Ƶ�800000
                    if a == 8388608
                        y = -8388607;%0x7fffff
                    else
                        % ȡ�����1
                       % y = -1*(bitcmp(a,24)+1);
                        y= -1*(bitxor(a,16777215)+1);
                    end
                else
                    y = a;
                
                end 
                
                recvData(1,i) = y/24*4500/8388607;  % ��ѹֵ����λmV
                
                
            end
            %������ݣ���ʽΪ 8*1��ͨ����*��������
            if comd==0
            mx_ContinuousData = reshape(recvData,8,1) ;        %��ѹֵ ��λ mV
           
            EegChData(1,t)= recvData(1,1); %�����һ��ͨ������ֵ�������������ͨ������EegChData(x,t)= recvData(1,x)
            EegChData(2,t)= recvData(1,2); %�����2��ͨ������ֵ��
             EegChData(3,t)= recvData(1,3); %�����3��ͨ������ֵ��
              EegChData(4,t)= recvData(1,4); %�����4��ͨ������ֵ��
               EegChData(5,t)= recvData(1,5); %�����5��ͨ������ֵ��
                EegChData(6,t)= recvData(1,6); %�����6��ͨ������ֵ��
                 EegChData(7,t)= recvData(1,7); %�����7��ͨ������ֵ��
                  EegChData(8,t)= recvData(1,8); %�����8��ͨ������ֵ��
            else
                ChalImp= reshape(20.9142*recvData-9.3071,8,1)  ;  %�迹���ԣ����迹���������¿��ã���λK��
            end
        else
            biterrorflag=1; % ֡����
            comd=2;
        end
    
          %biterrorflag=2; %����δ�յ�
    %end
   biterror(1,t) = biterrorflag;
   toc
end


 save eegdata EegChData;
 save  BitError biterror;
 drawnow;
 %toc
 %tic
 % DevID      %�豸ID

 %hold on;
 
end
%% Step4.������Դ
%% Implement the close figure callback
function localCloseFigure(figureHandle,~,tcp_Server)
%% ������Դ
comd=2;
delete(figureHandle);
fwrite(tcp_Server,[165 90 02 255 15],'uint8'); %�������豸���ͣ���ͣ���ݴ���
fclose(tcp_Server);
delete(tcp_Server);
% Close the figure window

%fclose(tcp_Server);
%delete(tcp_Server);