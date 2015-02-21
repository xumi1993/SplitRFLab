function SL_updatefiltered(seis)
% update the 3 component display after filtering

global thiseq  config eq
ny = round(1 / thiseq.dt / 2); %nyquist frequency
f1 = thiseq.filter(1);
f2 = thiseq.filter(2);

subax = get(seis,'Parent');
ya= findobj('Tag','TTimeAxesLable');

if f1==0 && f2==inf
    %no filter
    txt = sprintf('Preview(%.0f/%.0f): unfiltered', config.db_index, length(eq));
    if thiseq.system=='ENV'
        set(seis(1), 'Ydata',thiseq.Amp.East)
        set(seis(2), 'Ydata',thiseq.Amp.North)
        set(seis(3), 'Ydata',thiseq.Amp.Vert)
    elseif thiseq.system=='LTQ'
        set(seis(1), 'Ydata',thiseq.Amp.Radial)
        set(seis(2), 'Ydata',thiseq.Amp.Transv)
        set(seis(3), 'Ydata',thiseq.Amp.Ray)
    elseif thiseq.system=='RTZ'
        set(seis(1), 'Ydata',thiseq.Amp.R)
        set(seis(2), 'Ydata',thiseq.Amp.T)
        set(seis(3), 'Ydata',thiseq.Amp.Z)
    end
    set(ya, 'String', 'unfiltered')

else
    if f1 > 0  &&  f2 < inf
        % bandpass
        txt = sprintf('Preview(%.0f/%.0f): start= %.3fHz  stop= %0.2f Hz', config.db_index, length(eq),f1,f2 );
        [b,a]  = butter(3, [f1 f2]/ny);
        set(ya, 'String', sprintf('f_1 = %4.2f s   f_2 = %4.2f s',1./thiseq.filter))

    elseif f1==0 &&  f2 < inf
        %lowpass
        txt = sprintf('Preview(%.0f/%.0f): lowpass stop= %.2fHz', config.db_index, length(eq),f2 );
        [b,a]  = butter(3, [f2]/ny,'low');
        set(ya, 'String', sprintf('f = %4.2fs (lowpass)',1./f2))

    elseif f1>0 &&  f2 == inf
        %highpass
        txt = sprintf('Preview(%.0f/%.0f): highpass  start= %0.3f Hz', config.db_index, length(eq),f1 );
        [b,a]  = butter(3, [f1]/ny, 'high');
        set(ya, 'String', sprintf('f = %4.2fs (highpass)',1./f1))
    end

%%
E =  thiseq.Amp.East;
N =  thiseq.Amp.North;
Z =  thiseq.Amp.Vert;

Q = thiseq.Amp.Radial';
T = thiseq.Amp.Transv';
L = thiseq.Amp.Ray';

RR = thiseq.Amp.R;
TT = thiseq.Amp.T;
ZZ = thiseq.Amp.Z;

%% DeTrend & DeMean
    
    E = detrend(E,'linear');E = detrend(E,'constant');
    N = detrend(N,'linear');N = detrend(N,'constant');
    Z = detrend(Z,'linear');Z = detrend(Z,'constant');

    Q = detrend(Q,'linear');Q = detrend(Q,'constant');
    T = detrend(T,'linear');T = detrend(T,'constant');
    L = detrend(L,'linear');L = detrend(L,'constant');
    
    RR = detrend(RR,'linear');RR = detrend(RR,'constant');
    TT = detrend(TT,'linear');TT = detrend(TT,'constant');
    ZZ = detrend(ZZ,'linear');ZZ = detrend(ZZ,'constant');

%% Taper
  len  = round(length(E)*.03); %taper length is 3% of total seismogram length
  nn   = 1:len;
  nn2  = (length(E)-len+1):length(E);
  x    = linspace(pi, 2*pi, len);
taper  = 0.5 * (cos(x')+1);
taper2 = fliplr(taper);

% taper at begin           taper at end of seismogram
E(nn) = E(nn).*taper;    E(nn2) = E(nn2).*taper2;
N(nn) = N(nn).*taper;     N(nn2) = N(nn2).*taper2;
Z(nn) = Z(nn).*taper;     Z(nn2) = Z(nn2).*taper2;
Q(nn) = Q(nn).*taper;     Q(nn2) = Q(nn2).*taper2;
T(nn) = T(nn).*taper;     T(nn2) = T(nn2).*taper2;
L(nn) = L(nn).*taper;     L(nn2) = L(nn2).*taper2;
RR(nn) = RR(nn).*taper;     RR(nn2) = RR(nn2).*taper2;
TT(nn) = TT(nn).*taper;     TT(nn2) = TT(nn2).*taper2;
ZZ(nn) = ZZ(nn).*taper;     ZZ(nn2) = ZZ(nn2).*taper2;

%%
    
    
    
    
    

    %do filtering
    if thiseq.system=='ENV'
        Amp = (filtfilt(b, a, E));
        set(seis(1), 'Ydata',Amp)
        Amp = (filtfilt(b, a, N));
        set(seis(2), 'Ydata',Amp)
        Amp = (filtfilt(b, a, Z));
        set(seis(3), 'Ydata',Amp)
    elseif thiseq.system=='LTQ'
        Amp = (filtfilt(b, a, Q));
        set(seis(1), 'Ydata',Amp)
        Amp = (filtfilt(b, a, T));
        set(seis(2), 'Ydata',Amp)
        Amp = (filtfilt(b, a, L));
        set(seis(3), 'Ydata',Amp)
     elseif thiseq.system=='RTZ'
        Amp = (filtfilt(b, a, RR));
        set(seis(1), 'Ydata',Amp)
        Amp = (filtfilt(b, a, TT));
        set(seis(2), 'Ydata',Amp)
        Amp = (filtfilt(b, a, ZZ));
        set(seis(3), 'Ydata',Amp)
    end


end




switch thiseq.system
    case 'ENV'
        ylabel(subax{1}, 'East');
        ylabel(subax{2}, 'North')
        ylabel(subax{3}, 'Vertical')
    case 'LTQ'
        ylabel(subax{1}, 'Q');
        ylabel(subax{2}, 'T')
        ylabel(subax{3}, 'L')
    case 'RTZ'
        ylabel(subax{1}, 'R');
        ylabel(subax{2}, 'T')
        ylabel(subax{3}, 'Z')
    otherwise
        warning('unknown system given...')
end

set(get(subax{1},'Parent'), 'name', txt);
%% This program is part of SplitLab
% ?2006 Andreas W?tefeld, Universit?de Montpellier, France
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