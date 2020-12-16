function [bit_datas] = Fre_SK(fileName,message)
%�ַ���ת��Ϊ�������ַ�������,message��Ҫ������ַ�����ascii
originM = dec2bin(message,8);
%����dec2bin���ת��Ϊ
%�������ַ�����Ϊ���������飬��fliplr��ת����Ϊbi2de���ɵ�01���з���
datas = double(originM) - '0';      %�õ�0,1�ַ���
%������ż����λ
check_bit=mod(sum(datas'),2)';
datas=[datas,check_bit];

char_length=size(datas,2);    %���ǵ����ַ��ĳ���
str_length=size(datas,1);     %�����ַ����ĳ���

datas=reshape(datas',str_length*char_length,1);     %�����������ں�������


%����0 1 ����
fs = 48000;     %����Ƶ��
%��Ƹߵ�Ƶ��ʱ������λ����
f_low=960;     %FSK�ĵ�Ƶ����
f_high=2880;    %FSK�ĸ�Ƶ����

symbol_length=200;      %һ�������ַ���16��bit��һ��У��λ�������൱��1����30���ַ�
t_temp=(0:1/fs:(symbol_length-1)/fs);

%��0 1bit����һ��
sig_1=cos(2*pi*f_high*t_temp);
sig_0=cos(2*pi*f_low*t_temp);
%���Ҫ�����Ϊsig
sig = [];     %��ͷ����һ���հ�
bit_datas=[];   %��������bit��
sig_interval=zeros(1,symbol_length);  %��ͬ�ֶεļ��

%ǰ���벿�� �ظ�2�� 1011011��Ӧ����[
preamble = [];
preamble_order = [1,0,1,1,0,1,1];
for i = 1:length(preamble_order)
    if preamble_order(i) == 0
        preamble = [preamble,sig_0];
    else
        preamble = [preamble,sig_1];
    end
end
preamble = [preamble,preamble];

%�����벿�� �ظ�2��  1011101��Ӧ����]
epilog = [];
epilog_order = [1,0,1,1,1,0,1];
for i = 1:length(epilog_order)
    if epilog_order(i) == 0
        epilog = [epilog,sig_0];
    else
        epilog = [epilog,sig_1];
    end
end
epilog = [epilog,epilog];


%��������head����
flag=char_length<=8;

if flag
    head_length=floor(str_length/60)+1;
else
    head_length=floor(str_length/30)+1;
end

data_position=1;
for i=1:head_length
    header_code=[];
    head_index=double(dec2bin(i,8))-'0';
    head_bit=zeros(1,16);
    if i<head_length
        if flag
            data_length=60;
        else 
            data_length=30;
        end
    else
        if flag    
            data_length=str_length-(head_length-1)*60;
        else
            data_length=str_length-(head_length-1)*30;
        end
    end
    data_length1=double(dec2bin(data_length,8))-'0';
    for index = 1:8
        if head_index(index) == 0
            header_code = [header_code,sig_0];
            head_bit(index)=0;
        else
            header_code = [header_code,sig_1];
            head_bit(index)=1;
        end
    end
    
    for index = 1:8
        if data_length1(index) == 0
            header_code = [header_code,sig_0];
            head_bit(index+8)=0;
        else
            header_code = [header_code,sig_1];
            head_bit(index+8)=1;
        end
    end
    
    data_sig=zeros(1,symbol_length*data_length*char_length);
    bit_string=datas(data_position:data_position+data_length*char_length-1);   %ȡ�������ж�Ӧ�Ĳ���
    data_position=data_position+data_length*char_length;
    
    for bit_index=1:data_length*char_length
        if bit_string(bit_index)==0
            data_sig((bit_index-1)*symbol_length+1:bit_index*symbol_length)=sig_0; 
        else
            data_sig((bit_index-1)*symbol_length+1:bit_index*symbol_length)=sig_1; 
        end
    end
    
    
    sig_temp=[preamble,header_code,data_sig,epilog,sig_interval];      %����һ�εı���
    bit_data_temp=[preamble_order,preamble_order,head_bit,bit_string',epilog_order,epilog_order,0];
    bit_datas=[bit_datas,bit_data_temp];
    sig=[sig,sig_temp];
end

%�ⲿ�����ڹ����ŵ���ʧ
channel=sig_0+sig_1;
channel=[channel,channel];
channel=[channel,channel];
channel=[channel,channel]./2;

sig=[sig_interval,channel,sig_interval,sig,sig];     %�������Ե��ظ�����
bit_datas=[0,bit_datas,bit_datas];




%�ز�
% fc = 1000;
% t = 0:1/fs:(length(sig) - 1)/fs;
% carrier_wave = cos(2*pi*fc*t);
% sig_carrier = sig.*carrier_wave;
figure(1);
x=(1:1:length(sig))/fs;
plot(x,sig);

audiowrite([fileName,'.wav'],sig,fs);
end

