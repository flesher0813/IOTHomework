上个编解码的修正版
采用一个较长的chirp相关找到数据包头，数据间会用一个更窄的chirp分隔。
BFSK中0对应频率4kHz，1对应频率6kHz
接收信号后找到数据起始点，然后进行滤波，会同时滤出0、1频率，而chirp频率为1kHz~2kHz不会被滤出。
对信号分段计算二范数平方，如果超过一定阈值判定为有能量(这里需要考虑噪声的能量不能太大)
对有能量的部分进行归一化
分析频谱，在0、1频率对应范围内选出0、1，如果是对应chirp段默认为0

同时修改了编码的一些内容，如前导码为1011011只有7位，去除结束码
