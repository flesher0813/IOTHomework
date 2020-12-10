function xfinal=vad(x,fs,beta,Thres)
len = floor(20*fs/1000);            % Frame size in samples
if rem(len,2) == 1, len=len+1; end
PERC = 50;                          % window overlap in percent of frame size
len1 = floor(len*PERC/100);
len2 = len-len1;
                % VAD threshold in dB SNRseg
Expnt = 2;    % power exponent
G = 0.9;

win = hamming(len);

% Noise magnitude calculations - assuming that the first 5 frames is noise
nFFT = 2*2^nextpow2(len);
noise_mean = zeros(nFFT,1);
j=1;

for k = 1:5
    noise_mean = noise_mean+abs(fft(win.*x(j:j+len-1),nFFT));
    j = j+400;
end
noise_mu = noise_mean/5;

%--- allocate memory and initialize various variables
k = 1;
img = sqrt(-1);
x_old = zeros(len1,1);
Nframes = floor(length(x)/len2)-1;
xfinal = zeros(Nframes*len2,1);

%=========================    Start Processing   ===============================
for n = 1:Nframes
    insign = win.*x(k:k+len-1);      % Windowing
    spec = fft(insign,nFFT);         % compute fourier transform of a frame
    sig = abs(spec);                 % compute the magnitude
    %save the noisy phase information
    theta = angle(spec);
    SNRseg = 10*log10(norm(sig,2)^2/norm(noise_mu,2)^2);
%     if Expnt == 1.0     % ������
%         alpha = berouti1(SNRseg);
%     else
%         alpha = berouti(SNRseg); % ������
%     end
    alpha=1;
    %&&&&&&&&&
    sub_speech = sig.^Expnt - alpha*noise_mu.^Expnt;
    diffw = sub_speech - beta*noise_mu.^Expnt;     % �������ź�С�������źŵĹ���ʱ
    % beta negative components
    z = find(diffw <0);
    if~isempty(z)
        sub_speech(z) = beta*noise_mu(z).^Expnt;   % �ù��Ƴ����������źű�ʾ����ֵ
    %    sub_speech(z) = 0;
    %    sub_speech(z) = noise_mu(z).^Expnt;   % �ù��Ƴ����������źű�ʾ����ֵ
    end
    % --- implement a simple VAD detector --------------
    if (SNRseg < Thres)   % Update noise spectrum
        noise_temp = G*noise_mu.^Expnt+(1-G)*sig.^Expnt;    % ƽ����������������
        noise_mu = noise_temp.^(1/Expnt);                   % �µ�����������
    end
    % flipud����ʵ�־�������·�ת�����Ծ���ġ�ˮƽ���ߡ�Ϊ�Գ���
    %�������¶Գ�Ԫ��
    sub_speech(nFFT/2+2:nFFT) = flipud(sub_speech(2:nFFT/2));
    x_phase = (sub_speech.^(1/Expnt)).*(cos(theta)+img*(sin(theta)));
    % take the IFFT
    xi = real(ifft(x_phase));
    % --- Overlap and add ---------------
    xfinal(k:k+len2-1)=x_old+xi(1:len1);
    x_old = xi(1+len1:len);
    k = k+len2;
end

function a = berouti1(SNR)
if SNR >= -5.0 && SNR <= 20
    a = 3-SNR*2/20;
else
    if SNR < -5.0
        a = 4;
    end
    if SNR > 20
        a = 1;
    end
end

function a = berouti(SNR)
if SNR >= -5.0 && SNR <= 20
    a = 4-SNR*3/20;
else
    if SNR < -5.0
        a = 5;
    end
    if SNR > 20
        a = 1;
    end
end