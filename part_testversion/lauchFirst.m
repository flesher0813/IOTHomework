function [] = lauchFirst(fileName)

%信息是当前时间
message = datestr(now,'SS.FFF');
disp(message);
%生成声波信号
fsk(fileName,message);
%播放
[y, Fs] = audioread([fileName,'.wav']);
x = y(:, 1);
sound(y, Fs);
%输出播放结束时间
disp(datestr(now,'SS.FFF'));
end

