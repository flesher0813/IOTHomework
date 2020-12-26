function [] = playWav(fileName)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
[sig,Fs] = audioread(fileName);
sound(sig,Fs);
end

