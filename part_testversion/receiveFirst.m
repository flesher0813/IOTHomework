function [] = receiveFirst()
%UNTITLED3 此处显示有关此函数的摘要
% 从发出声音开始录音
%按照roundtrip的做法，只要我辨别出前导码，则可以认为接收到信号，
recordFileName = 'T1.wav';
timeLimit = 3;
receiveTime = datestr(now,'SS.FFF');
%recode(recordFileName,seconds);
realTimeRecord(recordFileName,timeLimit)
[peak_points,] = findPeak(recordFileName);
[sig,] = audioread(recordFileName);
%假如未录到信息
if length(peak_points) == 0
    disp('No valid message!');
    return
end

%假如录到信息，则录到信息的位置/总长*时间 + receiveTime = T1，按理说Pos只有一个
T1 = peak_points(1)/length(sig) * timeLimit;
T1 = str2num(receiveTime) + T1;
disp(totalTime);
%计算出时间差后，再向设备1发信息，马上发送
lauchSecond('T21.wav',T1);
end

