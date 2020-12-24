function [] = lauchSecond(fileName ,totalTime)
%生成时间差数据
disp(datestr(now,'SS.FFF'));
message = num2str(totalTime);
fsk(fileName,message);

%%播放
[y, Fs] = audioread([fileName,'.wav']);
x = y(:, 1);
sound(y, Fs);

%输出播放停止时间
disp(datestr(now,'SS.FFF'));
end

