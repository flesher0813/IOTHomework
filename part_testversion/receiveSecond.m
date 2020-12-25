function [] = receiveSecond(T0)
fileName = 'T30.wav';
timeLimit = 15;
%实际上T3不应该是now的时间，因为发送后设备2录音1s，实际有效的时间应该在0.2s
%，可以考虑测出实际有效时间,然后在T3的基础上剪，还有软硬件运行时间之类的
receiveTime = datestr(now,'SS.FFF');
disp(receiveTime);
realTimeRecord(fileName,timeLimit);
[peak_points,messages] = findPeak(fileName);
[sig,Fs] = audioread(fileName);
%假如未录到信息
if length(peak_points) == 0
    disp('No valid message!');
    return
end

%假如录到信息，则录到信息的位置/总长*时间+时间差应该是时间差，按理说Pos只有一个
T21 = str2num(translate(messages(3:3 + messages(2) - 1)));

disp(timeLimit);
disp(length(sig)/Fs)
T3 = peak_points(1)/Fs;
T3 = str2num(receiveTime) + T3;
disp(T3);
T30 = mod(60 + T3 - T0,60);
disp('T30')
disp(T30);
%totalTime = abs(T3 - T1) + preamblePos(1)/dataLength * seconds;

%平均时间
averageTime = (T30 - T21)/2;
disp('average Time:');
disp(averageTime);
voiceSpeed = 340;

%计算出时间差后，计算距离
distance = voiceSpeed * averageTime;
disp(distance);
end

