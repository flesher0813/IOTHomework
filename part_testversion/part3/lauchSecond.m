function [] = lauchSecond(fileName ,T1)
%生成时间差数据
T2 = str2num(datestr(now,'SS.FFF'));
deltaT = mod(T2 - T1 + 60,60);
disp(deltaT);
message = num2str(deltaT);
fsk(fileName,message);

%%播放
[y, Fs] = audioread(fileName);
sound(y, Fs);
pause(length(y)/Fs);
%输出播放停止时间
disp(datestr(now,'SS.FFF'));
end

