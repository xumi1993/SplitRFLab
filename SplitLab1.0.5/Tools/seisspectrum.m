function  seisspectrum
% Show spectrogram of radial component within time window

% This feature is still experimental
global thiseq


if ~isfield(thiseq, 'a')
    errordlg('Please select a time window first...')
    return
end
o  = thiseq.Amp.time(1);
ia = floor((thiseq.a-o)/thiseq.dt);
ib = ceil((thiseq.f-o)/thiseq.dt);

Q = thiseq.Amp.Radial(ia:ib);
T = thiseq.Amp.Transv(ia:ib);
%% Filtering
if thiseq.filter(1)>0   &  thiseq.filter(2)<inf %no filter
    n     = 3; %filter order
    ny    = 1/(2*thiseq.dt);
    wn    = [thiseq.filter(1) thiseq.filter(2)] / ny;
    [b,a] = butter(n, wn);
    Q = filtfilt(b,a,Q); %Radial     (Q) component in extended time window
    T = filtfilt(b,a,T); %Transverse (T) component in extended time window
end

%%
fig = findobj('name', 'Spectrum Viewer','type','figure');
if isempty(fig)
    figure('name', 'Spectrum Viewer',...
        'NumberTitle',     'off',...
        'Units','normalized',...
        'Position',[.33 .15 .33 .7])
else
    figure(fig)
    clf
end

%%
frequenz  = 1 /thiseq.dt;

nfft     = 2^nextpow2(16*frequenz); %for sampling frequency of 20Hz that is a window length of 256/20 = 12.8 sec
window   = hamming(frequenz);
noverlap = round(length(window)/2);


try
    ax(1)= subplot (2,1,1);
    spectrogram(Q, window, noverlap, nfft, frequenz,'yaxis')
    clim = caxis;

    ax(2) = subplot (2,1,2);
    spectrogram(T,  window, noverlap, nfft, frequenz,'yaxis')
    clim(3:4) = caxis;
catch
    e= errordlg({'Cannot run "spectrogram" function of Signal Processing Toolbox',lasterr});
    waitfor(e)
    close(gcf)
    return
end
    

tit={'Radial','Transverse'};
for k=1:2
    axes(ax(k));
shading interp
ylim([0 2])
set(gca,'Layer','top','color','none')
title(gca,{[tit{k} ' component Power Spectral Density [dB/Hz]'], 'This feature is still experimental !!!'})
grid on
m=round(max(clim)/10)*10;
caxis([0 m])
set(gcf,'Colormap',[nan nan nan; jet])
end

pos= get(ax(2),'position');

cb=colorbar('SouthOutside');
set(cb,'units','normalized','position',[.2 .03 .6 .02])
set(ax(2),'Position',pos)

%% This program is part of SplitLab
% © 2006 Andreas Wüstefeld, Université de Montpellier, France
%
% DISCLAIMER:
% 
% 1) TERMS OF USE
% SplitLab is provided "as is" and without any warranty. The author cannot be
% held responsible for anything that happens to you or your equipment. Use it
% at your own risk.
% 
% 2) LICENSE:
% SplitLab is free software; you can redistribute it and/or modifyit under the
% terms of the GNU General Public License as published by the Free Software 
% Foundation; either version 2 of the License, or(at your option) any later 
% version.
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
% more details.