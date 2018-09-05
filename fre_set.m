%用serial函数为指定串口创建一个串口对象，并返回该串口对象的句柄
s = serial('COM3');   
%设置该串口的波特率
s.BaudRate = 115200;  
%传送数据的位数
s.DataBits = 8;
% 奇偶校验
s.Parity = 'none';
%停止位位数
s.StopBits = 1;
%完成一次读写最大的等待时间
s.timeout = 0.5;
%打开串口，连接串口对象到外围设备
fopen(s);
%频率设置 初始值放在gui的openning函数中
Freq=[hex2dec('11'),hex2dec('22'),hex2dec('33'),hex2dec('44'),2,hex2dec('00'),...
   hex2dec('18'),hex2dec('00'),hex2dec('05'),    hex2dec('00'),hex2dec('00'),hex2dec('00'),...
   hex2dec('05'),    hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('14'),    hex2dec('00'),...
   hex2dec('00'),hex2dec('00'),hex2dec('14'),    hex2dec('00'),hex2dec('00'),hex2dec('00'),...
   hex2dec('32'), hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('32'), hex2dec('00'),...
   hex2dec('00'),hex2dec('00')];
%写数据到设备中
fwrite(s,Freq,'uint8') ;       
%关闭串口
fclose(s);
%删除串口
delete(s);
clear s;