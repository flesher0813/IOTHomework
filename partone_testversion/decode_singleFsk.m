function [payload,decode_message] = decode_singleFsk(fileName,onset)

[sig,fs] = audioread(fileName);
symbol_duration = 0.025;
symbol_len = fs*symbol_duration;
fs_low = 4000;
fs_high = 6000;
t = 0:1/fs:symbol_duration - 1/fs;
preamble = [0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1];

if onset + (length(preamble) + 8)*symbol_len - 1 > length(sig)
    payload = -1;
    decode_message = -1;
    return
end

%用一个包作检测
sig_ph = sig(onset:onset + (length(preamble) + 8)*symbol_len - 1);

decode_datas = getOriginalSig(sig_ph,symbol_len,fs,fs_low,fs_high);
%disp(decode_datas);
%前导码,获取包的长度
preamblePos = strfind(decode_datas,preamble);
if preamblePos + length(preamble) + 7 > length(decode_datas)
    payload = -1;
    decode_message = -1;
    return
end
header = decode_datas(preamblePos + length(preamble): preamblePos + length(preamble) + 7);
if length(header) < 8
    payload = -1;
    decode_message = -1;
    return
end
payload = bi2de(fliplr(header));
%disp(payload);
%解出message
sig_m = sig(onset + (length(preamble) + 8)*symbol_len:onset + (length(preamble) + 8 + payload)*symbol_len - 1);
decode_message = getOriginalSig(sig_m,symbol_len,fs,fs_low,fs_high);
%disp(decode_message);
end

