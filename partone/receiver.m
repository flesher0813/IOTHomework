clear; close all;clc;

% recObj=audiorecorder(48000,16,1);
% recordblocking(recObj,5);
% play(recObj);
% myRecording=getaudiodata(recObj);
% plot(myRecording);
% filename='decode.wav';
% audiowrite(filename,myRecording,48000);

filename='decode.wav';

[message,decode_datas,special,max_index]=Decode_Fsk(filename);
disp(message);


[music,fs]=audioread('Fsk_coder.wav');
[music_de,fs_de]=audioread('decode.wav');
figure;
subplot(3,1,1); hold on; box on;
plot(music);

music_de=music_de(max_index:max_index+length(music)-1);

subplot(3,1,2); hold on; box on;
plot(music_de);

subplot(3,1,3); hold on; box on;
plot(music-music_de);


% [music,fs]=audioread('decode.wav');
% sound(music,fs);

% filename='Fsk_coder.wav';
% [message,decode_datas,special]=Decode_Fsk(filename);
% disp(message);
