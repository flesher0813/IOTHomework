function [] = lauchFirst()
fileName = 'T0.wav';
%信息是当前时间
T0 = datestr(now,'SS.FFF');
%生成声波信号
fsk(fileName,T0);
%播放
[y, Fs] = audioread(fileName);
sound(y, Fs);
pause(length(y)/Fs);
disp(length(y)/Fs)
disp('lauch first');
disp(datestr(now,'SS.FFF'));
%输出播放结束时间
receiveSecond(str2num(T0));
end

