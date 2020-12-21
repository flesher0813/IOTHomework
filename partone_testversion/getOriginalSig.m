function [decode_datas] = getOriginalSig(sig,symbol_len,fs,fs_low,fs_high)
hd_low = design(fdesign.bandpass('N,F3dB1,F3dB2',6,fs_low - 500, fs_low + 500,fs),'butter');
sig_low = filter(hd_low,sig);

hd_high = design(fdesign.bandpass('N,F3dB1,F3dB2',6,fs_high - 500, fs_high + 500,fs),'butter');
sig_high = filter(hd_high,sig);

%figure
%subplot(311)
%plot(sig);
%subplot(312)
%plot(sig_low);
%subplot(313)
%plot(sig_high);

%包络
[low_upper,] = envelope(sig_low);
[high_upper,] = envelope(sig_high);

%判决
st = zeros(1,length(sig));
for i = 1:length(sig)
    if high_upper(i) > low_upper(i)
        st(i) = 1;
    end
end

%thresh
decode_datas = [];
thresh = symbol_len*0.6;
for i = 1:symbol_len:length(st)
    smb = st(i:i+symbol_len-1);
    A = sum(abs(smb));
    if A > thresh
        decode_datas = [decode_datas, 1];
    else
        decode_datas = [decode_datas, 0];
    end
end
end

