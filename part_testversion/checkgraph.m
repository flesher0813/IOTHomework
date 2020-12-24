function [] = checkgraph(normalWav)
%将两种方式产生的信号分别滤波展示，看看有什么不同
%normal
fs_low = 4000;
fs_high = 6000;

[normalSig,normalFs] = audioread(normalWav);
disp(normalFs);
hd_low = design(fdesign.bandpass('N,F3dB1,F3dB2',6,fs_low - 500, fs_low + 500,normalFs),'butter');
normalSig_low = filter(hd_low,normalSig);

hd_high = design(fdesign.bandpass('N,F3dB1,F3dB2',6,fs_high - 500, fs_high + 500,normalFs),'butter');
normalSig_high = filter(hd_high,normalSig);

[low_upper,] = envelope(normalSig_low);
[high_upper,] = envelope(normalSig_high);

figure(1)
subplot(511)
plot(normalSig);
subplot(512)
plot(normalSig_low);
subplot(513)
plot(normalSig_high);
subplot(514)
plot(low_upper);
subplot(515)
plot(high_upper);
end

