function [payload,decode_message] = decode_singleFsk(fileName,onset,preamble)

[sig,fs] = audioread(fileName);
symbol_duration = 0.025;
symbol_len = fs*symbol_duration;
fs_low = 4000;
fs_high = 6000;
t = 0:1/fs:symbol_duration - 1/fs;
%check前导码时前两个总会失真，去掉试试,有时可以读出，只能判定是玄学

%检查onset是否能用
if onset + (length(preamble) + 8)*symbol_len - 1 > length(sig) || onset < 0
    payload = -1;
    decode_message = -1;
    %warning('onset unsuitable\n');
    return
end

%用一个包作检测
sig_ph = sig(onset:onset + (length(preamble) + 8)*symbol_len - 1);

decode_datas = getOriginalSig(sig_ph,symbol_len,fs,fs_low,fs_high);

%前导码,获取包的长度
preamblePos = strfind(decode_datas,preamble);

%只是用于检查是否解析出正确的preamblePos

%检查解析出的数据是否够长
if preamblePos + length(preamble) + 7 > length(decode_datas)
    payload = -1;
    decode_message = -1;
    %warning('preamblePos unsuitable');
    return
end

header = decode_datas(preamblePos + length(preamble): preamblePos + length(preamble) + 7);
if length(header) < 8
    payload = -1;
    decode_message = -1;
    %warning('header unsuitable');
    return
end
payload = bi2de(fliplr(header));
%disp(payload);
%解出message

%disp(onset);

%只是用于检查是否解析出正确的preamblePos
%if preamblePos > 0
%    disp(preamblePos);
%    disp(payload);
%    disp(onset + (length(preamble) + 8 + payload)*symbol_len - 1);
%    disp(length(sig));
%end

%检查信息部分是否够长
if onset + (length(preamble) + 8 + payload)*symbol_len - 1 > length(sig)
    payload = -1;
    decode_message = -1;
    %warning('message unsuitable');
    return
end

sig_m = sig(onset + (length(preamble) + 8)*symbol_len:onset + (length(preamble) + 8 + payload)*symbol_len - 1);
decode_message = getOriginalSig(sig_m,symbol_len,fs,fs_low,fs_high);
%disp(translate(decode_message));
end

