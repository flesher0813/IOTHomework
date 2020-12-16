function [peak_points] = findPeak(fileName)
[sig,fs] = audioread(fileName);
fs_low = 4000;
fs_high = 6000;
symbol_duration = 0.025;
symbol_len = fs*symbol_duration;
t = 0:1/fs:symbol_duration - 1/fs;
preamble = [0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1];

smb0 = cos(2*pi*fs_low*t);
smb1 = cos(2*pi*fs_high*t);

%展示原信号
figure(1);
plot(sig)

%生成前导码
preamble_sig = [];
for i = 1:length(preamble)
    if preamble(i) < 1
        preamble_sig = [preamble_sig,smb0];
    else
        preamble_sig = [preamble_sig,smb1];
    end
end

%检查开头preamble是否正常

%用xcorr作互相关,遍历全段音频作互相关
onsets = [];
vals = [];
offsets = [];

for i = 1:symbol_len:length(sig)
    if i + (length(preamble))*symbol_len > length(sig)
        break;
    end
    sig_frame = sig(i:i + (length(preamble))*symbol_len - 1);
    [cofs,lags] = xcorr(sig_frame,preamble_sig);
    [val,idx] = max(cofs);
    offset = lags(idx);
    
    onsets = [onsets,i];
    vals = [vals,val];
    offsets = [offsets,offset];
end

%可能每每遍历选最大的，然后解码看看，再把相关的onset都删掉，再重复这个过程？
messages = [];
idx = -1;
val = 1001;
peak_points = [];
payload = 0;
while val > 1000
    [val,idx] = max(vals);
    offset = offsets(idx);
    onset = onsets(idx);
    
    if ~ismember(onset + offset,peak_points)
        [payload,decode_message] = decode_singleFsk(fileName,onset + offset);
        if payload > 0
            peak_points = [peak_points,onset + offset];
            offsets(idx:min(idx + length(preamble) + 8 + payload,length(offsets))) = [];
            onsets(idx:min(idx + length(preamble) + 8 + payload,length(onsets))) = [];
            vals(idx:min(idx + length(preamble) + 8 + payload,length(vals))) = [];
            messages = [messages,onset + offset,payload,decode_message]
        else
            offsets(idx) = [];
            onsets(idx) = [];
            vals(idx) = [];
        end
    else
        offsets(idx) = [];
        onsets(idx) = [];
        vals(idx) = [];
    end
end

%按顺序排列onset，解码可能在上一个部分实现，比如开一个矩阵，用个数组算了，找到起始点，后面一位就是长度
%每一列开头是起始点，然后payload和message，再按新peak_points的顺序获得message，再解码？
peak_points = sort(peak_points);
end
