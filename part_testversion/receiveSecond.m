function [] = receiveSecond(T1)
recordFileName = 'receiveMessage';
seconds = 1;
%实际上T3不应该是now的时间，因为发送后设备2录音1s，实际有效的时间应该在0.2s
%，可以考虑测出实际有效时间,然后在T3的基础上剪，还有软硬件运行时间之类的

T3 = str2num(datestr(now,'SS.FFF'));
recode(recordFileName,seconds);
[preamblePos,dataLength,message] = decodeFsk([recordFileName,'.wav']);

%假如未录到信息
if length(preamblePos) == 0
    disp('No valid message!');
    return
end

%假如录到信息，则录到信息的位置/总长*时间+时间差应该是时间差，按理说Pos只有一个
totalTime = abs(T3 - T1) + preamblePos(1)/dataLength * seconds;

%平均时间
averageTime = (totalTime - str2num(message))/2;
voiceSpeed = 340;

%计算出时间差后，计算距离
distance = voiceSpeed * averageTime;
end

