clear; close all;clc;
%message='爱我中华爱我中华爱我中华爱我中华爱我中华爱我中华爱我中华爱我中华爱我中华';
%message='abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890';
% message='1111111111222222222233333333331'
message='爱我中华爱我中华';
filename='Fsk_coder';
bit_datas=Fre_SK(filename,message);
% %disp(bit_datas);
% pause(2);

[music,fs]=audioread('Fsk_coder.wav');
sound(music,fs);

