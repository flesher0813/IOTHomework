function [] = receiver(timeLimit)

disp('Start recording');
recObj=audiorecorder(48000,16,1);
recordblocking(recObj,timeLimit);
disp('Stop recording');
%play(recObj);
myRecording=getaudiodata(recObj);
%plot(myRecording);
filename='decode1.wav';
audiowrite(filename,myRecording,48000);

filename='decode1.wav';
[message,decode_datas,max_index]=Decode_Fsk(filename);
disp(message);

% filename='Fsk_coder.wav';
% [message,decode_datas,max_index]=Decode_Fsk(filename);
% disp(message);
end



