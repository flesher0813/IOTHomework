function [] = fsk_chirp(message)
%放录误差太大了，换成一个chirp作前导码试试
%字符串转化为二进制字符串序列,message是要传输的字符串，ascii
originM = dec2bin(message,8);
%经过dec2bin后会转化为
%二进制字符串换为二进制数组，用fliplr翻转，因为bi2de生成的01序列反向
datas = double(originM) - '0';%得到0,1字符串
[rows,] = size(datas);

datas_bits = [];
for i = 1:rows
    datas_bits = [datas_bits,datas(i,:)];
end

message_len = length(datas_bits);

fs = 48000;
fs_low = 4000;
fs_high = 6000;
symbol_duration = 0.025;
t = 0:1/fs:symbol_duration - 1/fs;
preamble_t = 0:1/fs:4*symbol_duration - 1/fs;
preamble = chirp(preamble_t,fs_low - 500,4*symbol_duration - 1/fs, fs_high + 500);
%symbol_len = fs*symbol_duration;

%normal时
smb0 = cos(2*pi*fs_low*t);
smb1 = cos(2*pi*fs_high*t);

%使用chirp时
%smb0 = chirp(t,fs_low - 200,symbol_duration - 1/fs, fs_low + 200);
%smb1 = chirp(t,fs_high - 200,symbol_duration - 1/fs, fs_high + 200);

sig = [];

start_pos = 1;
bits_length = 0;
while message_len > 0
    %前导码
    sig = [sig,preamble];

    if message_len > 248 %31*8
        header = double(dec2bin(248,8)) - '0';
    else
        header = double(dec2bin(message_len,8)) - '0';
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
    
    pos_max = start_pos + min(message_len,248);
    while start_pos < pos_max
        if datas_bits(start_pos) < 1
            sig = [sig,smb0];
        else
            sig = [sig,smb1];
        end
        start_pos = start_pos + 1;
    end
    message_len = message_len - min(message_len,248);
    sig = [sig,zeros(1,symbol_duration*fs*4)];
end

disp(length(sig));
sig_carrier = awgn(sig, 20);
figure(1)
subplot(211)
plot(sig);
subplot(212)
plot(sig_carrier);
audiowrite('test_chirp.wav',sig,fs);
end

