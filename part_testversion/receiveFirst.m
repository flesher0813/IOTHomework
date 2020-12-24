function [] = receiveFirst()
%UNTITLED3 此处显示有关此函数的摘要
% 从发出声音开始录1s音
recordFileName = 'receiveMessage';
seconds = 1;
receiveTime = datestr(now,'SS.FFF');
recode(recordFileName,seconds);
[preamblePos,dataLength,message] = decodeFsk([recordFileName,'.wav']);

%假如未录到信息
if length(preamblePos) == 0
    disp('No valid message!');
    return
end

%假如录到信息，则录到信息的位置/总长*时间+时间差应该是时间差，按理说Pos只有一个
totalTime = preamblePos(1)/dataLength * seconds;
totalTime = abs(str2num(receiveTime) - str2num(message)) + totalTime;

%计算出时间差后，再向设备1发信息，马上发送
lauchSecond('secondLauch',totalTime);
end

