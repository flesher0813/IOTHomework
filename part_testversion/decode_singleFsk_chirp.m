function [payload,decode_message] = decode_singleFsk_chirp(fileName,onset)
[sig,fs] = audioread(fileName);
symbol_duration = 0.025;
symbol_len = fs*symbol_duration;
fs_low = 4000;
fs_high = 6000;
t = 0:1/fs:symbol_duration - 1/fs;
preamble_t = 0:1/fs:4*symbol_duration - 1/fs;
preamble = chirp(preamble_t,fs_low - 500,4*symbol_duration - 1/fs, fs_high + 500);

%检查onset是否能用
if onset + length(preamble) + 8*symbol_len - 1 > length(sig) || onset < 0
    payload = -1;
    decode_message = -1;
    %warning('onset unsuitable\n');
    return
end

%用一个包作检测
onsets = [];
vals = [];
offsets = [];

for i = 1:symbol_len:length(sig)
    if i + length(preamble) > length(sig)
        break;
    end
    sig_frame = sig(i:i + length(preamble) - 1);
    [cofs,lags] = xcorr(sig_frame,preamble);
    [val,idx] = max(cofs);
    offset = lags(idx);
    disp(val);
    onsets = [onsets,i];
    vals = [vals,val];
    offsets = [offsets,offset];
end

messages = [];
val = 100000;
peak_points = [];
payload = 0;
while val > 0
    [val,idx] = max(vals);
    offset = offsets(idx);
    onset = onsets(idx);
    disp(onset);
    disp(offset);
    offsets(idx) = [];
    onsets(idx) = [];
    vals(idx) = [];
end
%disp(tanslate(decode_message));
end

