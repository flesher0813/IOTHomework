function [] = checkByCsv(wavName,fileName)
%通过从csv中读取起始点解析
preamble = [0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1];
M = csvread(fileName,5,0);
[rows,] = size(M);
fid=fopen('test.csv','w+');
for i = 1:rows
    onset = M(i,4);
    [payload,decode_message] = decode_singleFsk(wavName,onset,preamble);
    fprintf(fid,'%d',payload);
    %disp(decode_message);
    for j = 1:payload
        fprintf(fid,',%d',decode_message(j));
    end
    fprintf(fid,'\n');
end
fclose(fid);
[sig,fs] = audioread(wavName);
figure
plot(sig);
end

