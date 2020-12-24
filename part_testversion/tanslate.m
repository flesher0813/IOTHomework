function [message] = tanslate(m_bits)

%接收后应该是先判断每段的开头（可能用自/互相关？），然后对每一个开头做decode_singleFsk
%m_bits = [];

%循环获得所有bit，按理来说应该是8的倍数
%[payload,decode_message] = decode_singleFsk(fileName,1);
%m_bits = [m_bits,decode_message];
disp('Translating...');
disp(length(m_bits));
message = [];
for i = 1:8:length(m_bits)
    word_bits = m_bits(i:min(i + 7,length(m_bits)));
    word = char(bi2de(fliplr(word_bits)));
    message = [message,word];
end
end

