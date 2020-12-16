function [] = fsk(message)
%字符串转化为二进制字符串序列,message是要传输的字符串，ascii
originM = dec2bin(message,8);
%经过dec2bin后会转化为
%二进制字符串换为二进制数组，用fliplr翻转，因为bi2de生成的01序列反向
datas = double(originM) - '0';%得到0,1字符串
preamble = [0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1];
[rows,col] = size(datas);
message_len = rows*col;
header = double(dec2bin(message_len,8)) - '0';

fs = 48000;
fs_low = 4000;
fs_high = 6000;
symbol_duration = 0.025;
t = 0:1/fs:symbol_duration - 1/fs;
%symbol_len = fs*symbol_duration;

smb0 = cos(2*pi*fs_low*t);
smb1 = cos(2*pi*fs_high*t);

sig = [];
%前导码
for i = 1:length(preamble)
    if preamble(i) < 1
        sig = [sig,smb0];
    else
        sig = [sig,smb1];
    end
end

%header
for i = 1:length(header)
    if header(i) < 1
        sig = [sig,smb0];
    else
        sig = [sig,smb1];
    end
end

%message
for i = 1:rows
    for j = 1:col
        if datas(i,j) < 1
            sig = [sig,smb0];
        else
            sig = [sig,smb1];
        end
    end
end

sig_carrier = awgn(sig, 20);
figure(1)
subplot(211)
plot(sig);
subplot(212)
plot(sig_carrier);
disp(datas);
audiowrite('test.wav',sig_carrier,fs);
end

