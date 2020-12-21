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

figure(1)
subplot(311)
plot(normalSig);
subplot(312)
plot(normalSig_low);
subplot(313)
plot(normalSig_high);
end

