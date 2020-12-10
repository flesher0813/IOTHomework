%message����ź��Ƿ���ȷ��preamblePos���ǰ����ĳ���λ��
%ֻ֧��ascii�����Ϣ�����header�����ֽ�(�������к��Լ������ַ���)�������255����
%��fsk�����������ݰ�ʱ���ܳɹ����??
function [message,decode_datas,special,max_index] = Decode_Fsk(fileName)
%ͨ����Ƶ�ļ�������ź�
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
%��0 1bit����һ��
sig_1=cos(2*pi*2880*t_temp);
sig_0=cos(2*pi*960*t_temp);

%��������ȼ����ŵ����Բ��ֵ�����
channel=sig_0+sig_1;
channel=[channel,channel];
channel=[channel,channel];
channel=[channel,channel]./2;

%�鿴������Ƶ�ź�ͼ
% figure;
% plot(sig);


%���ҵ���ʼλ�ã�0.1��Ӧ����100�����еĵ�2����������̫�����������ǰ����Ҫ����һ����һ��
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

%�˲�
fsk_low=zeros(1,length(sig));
fsk_high=zeros(1,length(sig));
hd_low = design(fdesign.bandpass('N,F3dB1,F3dB2',6,800,1100,fs),'butter');
hd_high = design(fdesign.bandpass('N,F3dB1,F3dB2',6,2700,3000,fs),'butter');
for i = 1:symbol_length:length(sig)
    smb = sig(i:min(i+symbol_length-1,length(sig)));
    rfsk1 = filter(hd_low,smb);
    rfsk2 = filter(hd_high,smb);
    fsk_low(i:min(i+symbol_length-1,length(sig))) = rfsk1;      %������ǵ�Ƶ��Ƶ�ֿ��ˣ���������ֵ�жϣ����ģ2�ϳ�
    fsk_high(i:min(i+symbol_length-1,length(sig))) = rfsk2;
end


%����
position=(1:symbol_length:length(sig));
symbol_0=ones(1,length(position));
symbol_1=zeros(1,length(position));     %����ź�Ϊ��������ģ2�ĺ�

%��ǰ��Ĳ��ֶ�����
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
    sigfor0=real(ifft(FFT_result0*NFFT/2,NFFT)); %ʵ�źŶ�Ӧ������Ƶ
    sigfor1=real(ifft(FFT_result1*NFFT/2,NFFT));
    if sum(sigfor0)>1    %��ֵʵ���ٿ�
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
sigfor0=real(ifft(FFT_result0*NFFT/2,NFFT)); %ʵ�źŶ�Ӧ������Ƶ
sigfor1=real(ifft(FFT_result1*NFFT/2,NFFT));
if sum(sigfor0)>1    %��ֵʵ���ٿ�
    symbol_0(length(position))=0;
end
if sum(sigfor1)>1
    symbol_1(length(position))=1;
end

decode_datas=double(symbol_0 & symbol_1);

special=[symbol_0;symbol_1];


%�ж�ǰ����
%ǰ����
preamble = [1,0,1,1,0,1,1];
preamble = [preamble,preamble];

%�ҳ���һ��ǰ�������г��ֵ�λ��
preamblePos = strfind(decode_datas,preamble);


message1=[];
position=1; %��ע��һ�����Ľ���λ��
for index=1:length(preamblePos)
   if preamblePos(index)<position
      continue; 
   end
   position=preamblePos(index);
   head_index=bi2de(fliplr(decode_datas(preamblePos(index)+14:preamblePos(index)+21)));     %bi2de�����Ƿ��ŵ�...u
   str_length=bi2de(fliplr(decode_datas(preamblePos(index)+22:preamblePos(index)+29)));
   message_temp=zeros(1,str_length+2);  %��¼head�����ȣ�������
   position=position+30;        %����һ������
   message_temp(1)=head_index;
   message_temp(2)=str_length;
   for word_index=1:str_length 
       if position+15<length(decode_datas)
           word=bi2de(fliplr(decode_datas(position:position+15)));
           if mod(sum(decode_datas(position:position+15)),2)==decode_datas(position+16)
               word=word*2;
           else
               word=word*2+1;
           end      %��wordģ2ֵ��Ϊ1˵������Ϊ0��ȷ
       else
           word=88;     %��Ӧ����*
       end
       message_temp(word_index+2)=word;
       position=position+17;        %��Ӧ��������ų���
   end
   position=position+14;            %�����˺�׺��
   message1=[message1,message_temp];
   
end


head_index=[];          %�õ����������Ϣ�а�ͷ����ʼ����
message_position=1;
while message_position<length(message1)
    head_index=[head_index,message_position];
    message_position=message_position+message1(message_position+1)+2;
end

head_value=message1(head_index);        %��ͷ����λ�ö�Ӧ�İ����
head_length=message1(head_index+1);     %�Լ����ĳ���


message=[];
head_num=max(head_value);    %�ҵ��ܵİ���
for number=1:head_num
    index=find(head_value==number);     %��������ش��汾
    if ~isempty(index)
        data_length=head_length(index);
        word_temp=zeros(1,data_length(1));
        for correct_index=1:data_length(1)     
            for num_index=1:length(index)       %�ش��Ĵ���
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

