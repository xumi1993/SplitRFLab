function fftsp
global thiseq


if ~isfield(thiseq, 'a')
    ia = 1;
    ib = length(thiseq.Amp.time);
else
o  = thiseq.Amp.time(1);
ia = floor((thiseq.a-o)/thiseq.dt);
ib = ceil((thiseq.f-o)/thiseq.dt);
end
R = thiseq.Amp.R(ia:ib);
T = thiseq.Amp.T(ia:ib);
Z = thiseq.Amp.Z(ia:ib);
%% Filtering
if thiseq.filter(1)>0   &&  thiseq.filter(2)<inf %no filter
    n     = 3; %filter order
    ny    = 1/(2*thiseq.dt);
    wn    = [thiseq.filter(1) thiseq.filter(2)] / ny;
    [b,a] = butter(n, wn);
    R = filtfilt(b,a,R); %Radial     (Q) component in extended time window
    T = filtfilt(b,a,T); %Transverse (T) component in extended time window
    Z = filtfilt(b,a,Z);
end
%% FFT
Fs = 1/thiseq.dt;
L = length(R);
NFFT = 2^nextpow2(L);
FR = fft(R,NFFT)/L;
FT = fft(T,NFFT)/L;
FZ = fft(Z,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

%% plot
color = [0 113/255 188/255];
fig = findobj('name', 'Amplitude - Frequency characteristics','type','figure');
if isempty(fig)
    figure('name', 'Amplitude - Frequency characteristics',...
        'NumberTitle',     'off',...
        'Units','normalized',...
        'Position',[.0 .15 .48 .8])
else
    figure(fig)
    clf
end
sh(1) = subplot(3,1,1);
loglog(f,abs(FR(1:NFFT/2+1)),'color',color);
sh(2) = subplot(3,1,2);
loglog(f,abs(FT(1:NFFT/2+1)),'color',color);
sh(3) = subplot(3,1,3);
loglog(f,abs(FZ(1:NFFT/2+1)),'color',color);

fig2 = findobj('name', 'Phase - frequency characteristics','type','figure');
if isempty(fig2)
    figure('name', 'Phase - frequency characteristics',...
        'NumberTitle',     'off',...
        'Units','normalized',...
        'Position',[.52 .15 .48 .8])
else
    figure(fig2)
    clf
end
ph(1) = subplot(3,1,1);
plot(f,angle(FR(1:NFFT/2+1)),'color',color);
ph(2) = subplot(3,1,2);
plot(f,angle(FT(1:NFFT/2+1)),'color',color);
ph(3) = subplot(3,1,3);
plot(f,angle(FZ(1:NFFT/2+1)),'color',color);

tit={'Radial','Transverse','Vertical'};

for i = 1:3
set(sh(i),'Xgrid','on','Ygrid','on','Yminorgrid','off','xlim',[f(1) f(end)],'yminortick','off');
xlabel(sh(i),'Frequency (Hz)');
ylabel(sh(i),'Amplitude');
title(sh(i),[tit{i} ' component amplitude spectrum'])
end 

for i = 1:3
set(ph(i),'Xgrid','on','Ygrid','on','Yminorgrid','off','xlim',[f(1) f(end)],'yminortick','off');
xlabel(ph(i),'Frequency (Hz)');
ylabel(ph(i),'Phase');
title(ph(i),[tit{i} ' component phase spectrum'])
end 