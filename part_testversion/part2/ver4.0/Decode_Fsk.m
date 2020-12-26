%message检测信号是否正确，preamblePos检测前导码的出现位置
%只支持ascii码的信息，设计header两个字节(包的序列号以及里面字符数)，最多有255个包
%当fsk编码两个数据包时才能成功解读??
function [message,decode_datas,max_index] = Decode_Fsk(fileName)
%通过音频文件名获得信号
[sig,fs] = audioread(fileName);
sig=sig(:,1)/max(sig(:,1));
symbol_length = 500;
f_low=1000;     %FSK的低频部分
f_high=1500;    %FSK的高频部分

%%%
figure;
time_x=(1:length(sig))/fs;
subplot(3,1,1); hold on; box on;
plot(time_x,sig);
%%%


% figure;
% subplot(3,1,1); hold on; box on;
% plot(sig);
% beta = 0.001;
% Thres = 0.1;
% sig1=vad(sig,fs,beta,Thres);
% subplot(3,1,2); hold on; box on;
% plot(sig1);
% subplot(3,1,3); hold on; box on;
% plot(sig(1:length(sig1))-sig1);
% sig=sig1;


%t_temp=(0:1/fs:(symbol_length-1)/fs);
chirp_temp=(0:1/fs:(4*symbol_length-1)/fs);
%给0 1bit生成一段
% sig_1=cos(2*pi*f_high*t_temp);
% sig_0=cos(2*pi*f_low*t_temp);
%sig_chirp是数据包之间的间隔，channel是起始部分
%sig_chirp=chirp(t_temp,1000,symbol_length/fs,2000)
channel=chirp(chirp_temp,2000,4*symbol_length/fs,4000);

%查看输入音频信号图
% figure;
% plot(sig);

%先找到起始位置，0.1对应的是100个点中的第2个，不会有太大的误差，不过在前面需要先做一步归一化
sig_index=find(abs(sig)>0.25);

max_index=1;
max_corr=0;
if ~isempty(sig_index)   %channel毕竟重复了两遍，考虑预热的问题，选择后一个channel做相关
    for index=sig_index(1)-20+4*symbol_length:1:sig_index(1)+10+4*symbol_length
        current_corr=sum(sig(index:index+length(channel)-1)'.*channel);
        if abs(current_corr)>abs(max_corr)
            max_corr=current_corr;
            max_index=index;
        end
    end
end

%disp(['max_corr  ',max_corr]);

sig=sig(max_index+4*symbol_length:length(sig))';
max_index=max_index-4*symbol_length;

%%%
subplot(3,1,2); hold on; box on;
plot((1:1:length(sig))/fs,sig);
%%%


%滤波
fsk_decode=zeros(1,length(sig));
hd_decode = design(fdesign.bandpass('N,F3dB1,F3dB2',6,600,1800,fs),'butter');
for i = 1:symbol_length:length(sig)
    smb = sig(i:min(i+symbol_length-1,length(sig)));
    rfsk = filter(hd_decode,smb);
    if sum(rfsk.^2)>symbol_length/50
        fsk_decode(i:min(i+symbol_length-1,length(sig))) = rfsk./max(rfsk);      %整个频率滤出来，同时按照最高值进行归一化，这里加入能量判断
    else
        fsk_decode(i:min(i+symbol_length-1,length(sig))) = rfsk;
    end
end

%%%
subplot(3,1,3); hold on; box on;
plot((1:1:length(fsk_decode))/fs,fsk_decode);
%%%


%解码
position=(1:symbol_length:length(sig));
symbol=zeros(1,length(position));     %最后信号解码出来的bit

%把前面的部分都解码
NFFT=symbol_length;
fx=(0:NFFT/2-1)*fs/NFFT; 
for index=1:length(position)-1
%    pre_for0=fsk_decode(position(index):position(index)+symbol_length-1).*sig_0;
%    pre_for1=fsk_decode(position(index):position(index)+symbol_length-1).*sig_1;
    
    result_temp=fft(fsk_decode(position(index):position(index)+symbol_length-1),NFFT);
    result_temp1=result_temp(1:length(fx));
    [peak,pos]=max(abs(result_temp1));
    if peak>symbol_length/8 && fx(pos)<f_high+100 && fx(pos)>f_high-100
        symbol(index)=1;
    elseif peak>symbol_length/8 && fx(pos)<f_low+100 && fx(pos)>f_low-100
        symbol(index)=0;
    else
        symbol(index)=0;
    end
    
%     flag_for0=sum(pre_for0);
%     flag_for1=sum(pre_for1);
%     if flag_for0>symbol_length/4 && flag_for1<symbol_length/4    %阈值实验再看,低频直流到高频直流未到为0
%         symbol(index)=0;
%     elseif flag_for1>symbol_length/4 && flag_for0<symbol_length/4    %低频直流不到高频直流到为1
%         symbol(index)=1;
%     else                                                             %其他时候认为无信号默认0？
%         symbol(index)=0;
%     end

end
NFFT=length(0:1/fs:(length(sig)-position(length(position)))/fs);
fx=(0:NFFT/2-1)*fs/NFFT; 
result_temp=fft(fsk_decode(position(length(position)):length(sig)),NFFT);
result_temp1=result_temp(1:length(fx));
[peak,pos]=max(abs(result_temp1));
% t_temp1=(0:1/fs:(length(sig)-position(length(position)))/fs);
% sig_1_temp=cos(2*pi*f_high*t_temp1);
% sig_0_temp=cos(2*pi*f_low*t_temp1);
% pre_for0=fsk_decode(position(length(position)):length(sig)).*sig_0_temp;
% pre_for1=fsk_decode(position(length(position)):length(sig)).*sig_1_temp;
% flag_for0=sum(pre_for0);
% flag_for1=sum(pre_for1);
if peak>symbol_length/8 && fx(pos)<f_high+100 &&fx(pos)>f_high-100
    symbol(length(position))=1;
elseif peak>symbol_length/8 && fx(pos)<f_low+100 &&fx(pos)>f_low-100
    symbol(index)=0;
else
    symbol(index)=0;
end
% 
% if flag_for0>symbol_length/4 && flag_for1<symbol_length/4    %阈值实验再看,低频直流到高频直流未到为0
%     symbol(length(position))=0;
% elseif flag_for1>symbol_length/4 && flag_for0<symbol_length/4    %低频直流不到高频直流到为1
%     symbol(length(position))=1;
% else                                                             %其他时候认为无信号默认0？
%     symbol(length(position))=0;
% end

decode_datas=symbol;

%判断前导码
%前导码
preamble = [1,0,1,1,0,1,1];
%preamble = [preamble,preamble];

%找出第一个前导码序列出现的位置
preamblePos = strfind(decode_datas,preamble);


message1=[];
position=1; %标注上一个包的结束位置
for index=1:length(preamblePos)
   if preamblePos(index)<position
      continue; 
   end
   position=preamblePos(index);
   head_index=bi2de(fliplr(decode_datas(preamblePos(index)+7:preamblePos(index)+14)));     %bi2de函数是反着的...u
   str_length=bi2de(fliplr(decode_datas(preamblePos(index)+15:preamblePos(index)+22)));
   message_temp=zeros(1,str_length+2);  %记录head，长度，数据项
   position=position+23;        %到第一个数据
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
%   position=position+14;            %跳过了后缀码
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

