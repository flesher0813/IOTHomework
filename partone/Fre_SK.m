function [bit_datas] = Fre_SK(fileName,message)
%字符串转化为二进制字符串序列,message是要传输的字符串，ascii
originM = dec2bin(message,8);
%经过dec2bin后会转化为
%二进制字符串换为二进制数组，用fliplr翻转，因为bi2de生成的01序列反向
datas = double(originM) - '0';      %得到0,1字符串
%加上奇偶检验位
check_bit=mod(sum(datas'),2)';
datas=[datas,check_bit];

char_length=size(datas,2);    %这是单个字符的长度
str_length=size(datas,1);     %这是字符串的长度

datas=reshape(datas',str_length*char_length,1);     %拉成向量用于后续操作


%生成0 1 序列
fs = 48000;     %采样频率
%设计高低频的时候考虑相位连续
f_low=960;     %FSK的低频部分
f_high=2880;    %FSK的高频部分

symbol_length=200;      %一个中文字符有16的bit加一个校验位，这样相当于1秒大概30个字符
t_temp=(0:1/fs:(symbol_length-1)/fs);

%给0 1bit生成一段
sig_1=cos(2*pi*f_high*t_temp);
sig_0=cos(2*pi*f_low*t_temp);
%最后要传输的为sig
sig = [];     %开头先有一个空白
bit_datas=[];   %用来给出bit串
sig_interval=zeros(1,symbol_length);  %不同分段的间隔

%前导码部分 重复2次 1011011对应的是[
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

%结束码部分 重复2次  1011101对应的是]
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


%接下来是head部分
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
    bit_string=datas(data_position:data_position+data_length*char_length-1);   %取出数据中对应的部分
    data_position=data_position+data_length*char_length;
    
    for bit_index=1:data_length*char_length
        if bit_string(bit_index)==0
            data_sig((bit_index-1)*symbol_length+1:bit_index*symbol_length)=sig_0; 
        else
            data_sig((bit_index-1)*symbol_length+1:bit_index*symbol_length)=sig_1; 
        end
    end
    
    
    sig_temp=[preamble,header_code,data_sig,epilog,sig_interval];      %这是一段的编码
    bit_data_temp=[preamble_order,preamble_order,head_bit,bit_string',epilog_order,epilog_order,0];
    bit_datas=[bit_datas,bit_data_temp];
    sig=[sig,sig_temp];
end

%这部分用于估计信道损失
channel=sig_0+sig_1;
channel=[channel,channel];
channel=[channel,channel];
channel=[channel,channel]./2;

sig=[sig_interval,channel,sig_interval,sig,sig];     %先象征性的重复两遍
bit_datas=[0,bit_datas,bit_datas];




%载波
% fc = 1000;
% t = 0:1/fs:(length(sig) - 1)/fs;
% carrier_wave = cos(2*pi*fc*t);
% sig_carrier = sig.*carrier_wave;
figure(1);
x=(1:1:length(sig))/fs;
plot(x,sig);

audiowrite([fileName,'.wav'],sig,fs);
end

