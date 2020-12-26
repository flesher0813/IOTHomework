function [] = receiveFirst()
%UNTITLED3 此处显示有关此函数的摘要
% 从发出声音开始录音
%按照roundtrip的做法，只要我辨别出前导码，则可以认为接收到信号，
recordFileName = 'T1.wav';
timeLimit = 5;
receiveTime = datestr(now,'SS.FFF');
%recode(recordFileName,seconds);
realTimeRecord(recordFileName,timeLimit)
[peak_points,] = findPeak(recordFileName);
[sig,Fs] = audioread(recordFileName);
%假如未录到信息
if length(peak_points) == 0
    disp('No valid message!');
    return
end


disp(timeLimit);
disp(length(sig)/Fs)
%假如录到信息，则录到信息的位置/总长*时间 + receiveTime = T1，按理说Pos只有一个
T1 = peak_points(1)/Fs;
T1 = str2num(receiveTime) + T1;
disp(T1);
%计算出时间差后，再向设备1发信息，马上发送
lauchSecond('T21.wav',T1);
end

