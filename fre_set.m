%��serial����Ϊָ�����ڴ���һ�����ڶ��󣬲����ظô��ڶ���ľ��
s = serial('COM3');   
%���øô��ڵĲ�����
s.BaudRate = 115200;  
%�������ݵ�λ��
s.DataBits = 8;
% ��żУ��
s.Parity = 'none';
%ֹͣλλ��
s.StopBits = 1;
%���һ�ζ�д���ĵȴ�ʱ��
s.timeout = 0.5;
%�򿪴��ڣ����Ӵ��ڶ�����Χ�豸
fopen(s);
%Ƶ������ ��ʼֵ����gui��openning������
Freq=[hex2dec('11'),hex2dec('22'),hex2dec('33'),hex2dec('44'),2,hex2dec('00'),...
   hex2dec('18'),hex2dec('00'),hex2dec('05'),    hex2dec('00'),hex2dec('00'),hex2dec('00'),...
   hex2dec('05'),    hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('14'),    hex2dec('00'),...
   hex2dec('00'),hex2dec('00'),hex2dec('14'),    hex2dec('00'),hex2dec('00'),hex2dec('00'),...
   hex2dec('32'), hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('32'), hex2dec('00'),...
   hex2dec('00'),hex2dec('00')];
%д���ݵ��豸��
fwrite(s,Freq,'uint8') ;       
%�رմ���
fclose(s);
%ɾ������
delete(s);
clear s;