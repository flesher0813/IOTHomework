clear; close all;clc;
%message='�����л������л������л������л������л������л������л������л������л�';
%message='abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890';
% message='1111111111222222222233333333331'
message='�����л������л�';
filename='Fsk_coder';
bit_datas=Fre_SK(filename,message);
% %disp(bit_datas);
% pause(2);

[music,fs]=audioread('Fsk_coder.wav');
sound(music,fs);

