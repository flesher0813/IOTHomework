%message检测信号是否正确，preamblePos检测前导码的出现位置
%只支持ascii码的信息，设计header两个字节(包的序列号以及里面字符数)，最多有255个包
%当fsk编码两个数据包时才能成功解读??
function [message,decode_datas,special,max_index] = Decode_Fsk(fileName)
%通过音频文件名获得信号
[sig,fs] = audioread(fileName);
symbol_length = 200;



figure;
subplot(3,1,1); hold on; box on;
plot(sig);
beta = 0.001;
Thres = 0.1;
sig1=vad(sig,fs,beta,Thres);
subplot(3,1,2); hold on; box on;
plot(sig1);
subplot(3,1,3); hold on; box on;
plot(sig-sig1);
sig=sig1;


t_temp=(0:1/fs:(symbol_length-1)/fs);
%给0 1bit生成一段
sig_1=cos(2*pi*2880*t_temp);
sig_0=cos(2*pi*960*t_temp);

%利用相关先检测出信道测试部分的数据
channel=sig_0+sig_1;
channel=[channel,channel];
channel=[channel,channel];
channel=[channel,channel]./2;

%查看输入音频信号图
% figure;
% plot(sig);


%先找到起始位置，0.1对应的是100个点中的第2个，不会有太大的误差，不过在前面需要先做一步归一化
sig_index=find(abs(sig)>0.3);

max_index=1;
max_corr=0;
if ~isempty(sig_index)
    for index=sig_index(1)-50:1:sig_index(1)+10
        current_corr=sum(sig(index:index+length(channel)-1)'.*channel);
        if current_corr>max_corr
            max_corr=current_corr;
            max_index=index;
        end
    end
end

sig=sig(max_index:length(sig))';

%滤波
fsk_low=zeros(1,length(sig));
fsk_high=zeros(1,length(sig));
hd_low = design(fdesign.bandpass('N,F3dB1,F3dB2',6,800,1100,fs),'butter');
hd_high = design(fdesign.bandpass('N,F3dB1,F3dB2',6,2700,3000,fs),'butter');
for i = 1:symbol_length:length(sig)
    smb = sig(i:min(i+symbol_length-1,length(sig)));
    rfsk1 = filter(hd_low,smb);
    rfsk2 = filter(hd_high,smb);
    fsk_low(i:min(i+symbol_length-1,length(sig))) = rfsk1;      %我想的是低频高频分开滤，可以用阈值判断，最后模2合成
    fsk_high(i:min(i+symbol_length-1,length(sig))) = rfsk2;
end


%解码
position=(1:symbol_length:length(sig));
symbol_0=ones(1,length(position));
symbol_1=zeros(1,length(position));     %最后信号为上面两个模2的和

%把前面的部分都解码
NFFT=symbol_length;
for index=1:length(position)-1
    pre_for0=fsk_low(position(index):position(index)+symbol_length-1).*sig_0;
    pre_for1=fsk_high(position(index):position(index)+symbol_length-1).*sig_1;
    
    FFT_result0=fft(pre_for0,NFFT);
    FFT_result1=fft(pre_for1,NFFT);
    fx=(0:NFFT/2-1)*fs/NFFT;   
    FFT_result0=FFT_result0/NFFT*2;
    FFT_result1=FFT_result1/NFFT*2;
    index_low=find(fx<=100);
    revise_low=zeros(NFFT/2,1);
    revise_low(1:index_low(length(index_low)))=1;
    FFT_result0=FFT_result0(1:NFFT/2);
    FFT_result1=FFT_result1(1:NFFT/2);
    FFT_result0=FFT_result0.*revise_low';       
    FFT_result1=FFT_result1.*revise_low';
    FFT_result0(2:length(FFT_result0))=2*FFT_result0(2:length(FFT_result0));
    FFT_result1(2:length(FFT_result1))=2*FFT_result1(2:length(FFT_result1));
    sigfor0=real(ifft(FFT_result0*NFFT/2,NFFT)); %实信号对应的是音频
    sigfor1=real(ifft(FFT_result1*NFFT/2,NFFT));
    if sum(sigfor0)>1    %阈值实验再看
        symbol_0(index)=0;
    end
    if sum(sigfor1)>1
        symbol_1(index)=1;
    end
end

NFFT=length(sig)-position(length(position))+1;
t_temp1=(0:1/fs:(length(sig)-position(length(position)))/fs);
sig_1=cos(2*pi*2880*t_temp1);
sig_0=cos(2*pi*960*t_temp1);
pre_for0=fsk_low(position(length(position)):length(sig)).*sig_0;
pre_for1=fsk_high(position(length(position)):length(sig)).*sig_1;
FFT_result0=fft(pre_for0,NFFT);
FFT_result1=fft(pre_for1,NFFT);
fx=(0:NFFT/2-1)*fs/NFFT;   
FFT_result0=FFT_result0/NFFT*2;
FFT_result1=FFT_result1/NFFT*2;
index_low=find(fx<=100);
revise_low=zeros(floor(NFFT/2),1);
revise_low(1:index_low(length(index_low)))=1;
FFT_result0=FFT_result0(1:floor(NFFT/2));
FFT_result1=FFT_result1(1:floor(NFFT/2));
FFT_result0=FFT_result0.*revise_low';       
FFT_result1=FFT_result1.*revise_low';
FFT_result0(2:length(FFT_result0))=2*FFT_result0(2:length(FFT_result0));
FFT_result1(2:length(FFT_result1))=2*FFT_result1(2:length(FFT_result1));
sigfor0=real(ifft(FFT_result0*NFFT/2,NFFT)); %实信号对应的是音频
sigfor1=real(ifft(FFT_result1*NFFT/2,NFFT));
if sum(sigfor0)>1    %阈值实验再看
    symbol_0(length(position))=0;
end
if sum(sigfor1)>1
    symbol_1(length(position))=1;
end

decode_datas=double(symbol_0 & symbol_1);

special=[symbol_0;symbol_1];


%判断前导码
%前导码
preamble = [1,0,1,1,0,1,1];
preamble = [preamble,preamble];

%找出第一个前导码序列出现的位置
preamblePos = strfind(decode_datas,preamble);


message1=[];
position=1; %标注上一个包的结束位置
for index=1:length(preamblePos)
   if preamblePos(index)<position
      continue; 
   end
   position=preamblePos(index);
   head_index=bi2de(fliplr(decode_datas(preamblePos(index)+14:preamblePos(index)+21)));     %bi2de函数是反着的...u
   str_length=bi2de(fliplr(decode_datas(preamblePos(index)+22:preamblePos(index)+29)));
   message_temp=zeros(1,str_length+2);  %记录head，长度，数据项
   position=position+30;        %到第一个数据
   message_temp(1)=head_index;
   message_temp(2)=str_length;
   for word_index=1:str_length 
       if position+15<length(decode_datas)
           word=bi2de(fliplr(decode_datas(position:position+15)));
           if mod(sum(decode_datas(position:position+15)),2)==decode_datas(position+16)
               word=word*2;
           else
               word=word*2+1;
           end      %看word模2值，为1说明出错，为0正确
       else
           word=88;     %对应的是*
       end
       message_temp(word_index+2)=word;
       position=position+17;        %对应于这个符号长度
   end
   position=position+14;            %跳过了后缀码
   message1=[message1,message_temp];
   
end


head_index=[];          %得到解码出的消息中包头的起始索引
message_position=1;
while message_position<length(message1)
    head_index=[head_index,message_position];
    message_position=message_position+message1(message_position+1)+2;
end

head_value=message1(head_index);        %包头索引位置对应的包编号
head_length=message1(head_index+1);     %以及包的长度


message=[];
head_num=max(head_value);    %找到总的包数
for number=1:head_num
    index=find(head_value==number);     %这个包的重传版本
    if ~isempty(index)
        data_length=head_length(index);
        word_temp=zeros(1,data_length(1));
        for correct_index=1:data_length(1)     
            for num_index=1:length(index)       %重传的次数
                if mod(message1(head_index(index(num_index))+1+correct_index),2)==0
                    word_temp(correct_index)=floor(message1(head_index(index(num_index))+1+correct_index)/2);
                    break;
                end
            end
        end
    else
        word_temp=[];
    end
    message=[message,word_temp];
end

message=char(message);


end

