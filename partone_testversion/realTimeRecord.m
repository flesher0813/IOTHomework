function [] = realTimeRecord()
fs = 48000;
timeLength=0.1;            % 采样时长，单位秒
samples=timeLength*fs;  % 默认采样率48000，计算采样点数
deviceReader = audioDeviceReader(fs,samples);
setup(deviceReader);
[audioIn,~] = deviceReader();                     % 第一次采样

figure('Name','实时频谱','MenuBar'...
    ,'none','ToolBar','none','NumberTitle','off');
xdata=(1:1:samples/2)/timeLength;          
axes1= subplot(1,2,1);
axes2= subplot(1,2,2);
pic= plot(axes1, 1:1:samples, audioIn);    % 初始化音频波形图
pic2= bar(axes2,xdata, xdata*0,'r');       % 初始化频谱图
set(axes1,'xlim', [0 samples], 'ylim', ...
    [-0.01 0.01],'XTick',[],'YTick',[] );
set(axes2,'xlim', [min(xdata) max(xdata)], 'ylim',[0 6] , ...
     'xscale','log','XTick',[1 10 100 1e3 1e4],'YTick',[] );
xlabel(axes2,'频率 (Hz)');
xlabel(axes1,'波形');
axes2.Position=[0.040 0.48 00.92 0.48]; % 左，下，宽度，高度
axes1.Position=[0.040 0.06 0.92 0.25];
drawnow;

%录音10s
fileWriter = dsp.AudioFileWriter('mySpeech.wav','FileFormat','WAV','SampleRate',fs);
%tic
 while 2 < 3
   %disp(toc);
   [audioIn,Overrun] = deviceReader();        % 采样
   if Overrun > 0
      warning('  数据溢出 %d 位\n',Overrun);
   end
   
   if strcmpi(get(gcf,'CurrentCharacter'),'e')
       disp('press e');
       break;
   end
    
   ydata_fft=fft(audioIn);             % 傅里叶变换
   ydata_abs=abs(ydata_fft(1:samples/2));% 取绝对值
   set(pic, 'ydata',audioIn);          % 更新波形图数据
   set(pic2, 'ydata',log(ydata_abs));  % 更新频谱图数据
   drawnow;                            % 刷新
   fileWriter(audioIn);
   
 end
 disp('done');
 release(fileWriter);
 release(deviceReader);
end

