function preSplit
%% pre-processing of Shear-wave splitting
% necessary inputs:
% e, n, z, t   = amplitude and time vectors
%                raw data in geographic system
%                these will be rotated, filtered and detrended
% bazi, incli  = backazimuth and inclinationn of wave
% a, f         = begin and end of selection window (in sec)
%
% OUTPUT:
%

%%
global thiseq config eq

fprintf(' %s -- Estimating event  %s:%4.0f.%03.0f (%.0f/%.0f) --',...
    datestr(now,13) , config.stnname, thiseq.date(1), thiseq.date(7),config.db_index, length(eq));


  
%% extend selection window    
extime    = 20 ;%extend by 20sec
o         = thiseq.Amp.time(1);%common offset of all files after hypotime
extbegin  = floor( (thiseq.a-extime-o) / thiseq.dt); 
extfinish = floor( (thiseq.f+extime-o) / thiseq.dt); 
extIndex  = extbegin:extfinish;

% indices of selection window relative to extended window
ex = floor(extime/thiseq.dt) ;
w  = (ex+1):(length(extIndex)-ex);


%%
E =  thiseq.Amp.East;
N =  thiseq.Amp.North;
Z =  thiseq.Amp.Vert;

Q = thiseq.Amp.Radial';
T = thiseq.Amp.Transv';
L = thiseq.Amp.Ray';

%% DeTrend & DeMean
    
    E = detrend(E,'linear');E = detrend(E,'constant');
    N = detrend(N,'linear');N = detrend(N,'constant');
    Z = detrend(Z,'linear');Z = detrend(Z,'constant');

    Q = detrend(Q,'linear');Q = detrend(Q,'constant');
    T = detrend(T,'linear');T = detrend(T,'constant');
    L = detrend(L,'linear');L = detrend(L,'constant');

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


%% Filtering
% the seismogram components are not yet filtered
% define your filter here.
% the selected corner frequncies are stored in the varialbe "thiseq.filter"
% 
ny    = 1/(2*thiseq.dt);%nyquist freqency of seismogramm
n     = 3; %filter order
f1 = thiseq.filter(1);
f2 = thiseq.filter(2);
if f1==0 & f2==inf %no filter
    % do nothing
    % we leave the seismograms untouched
else
    if f1 > 0  &  f2 < inf
        % bandpass
        [b,a]  = butter(n, [f1 f2]/ny);
    elseif f1==0 &  f2 < inf
        %lowpass
        [b,a]  = butter(n, [f2]/ny,'low');

    elseif f1>0 &  f2 == inf
        %highpass
        [b,a]  = butter(n, [f1]/ny, 'high');
    end
    Q = filtfilt(b,a,Q); %Radial     (Q) component in extended time window
    T = filtfilt(b,a,T); %Transverse (T) component in extended time window
    L = filtfilt(b,a,L); %Vertical   (L) component in extended time window
    
 
    E = filtfilt(b,a,E); %East, only needed for particle motion plot
    N = filtfilt(b,a,N); %North, only needed for particle motion plot  
end

%% Cut to extended window


E = E(extIndex);
N = N(extIndex);
Z = Z(extIndex);
Q = Q(extIndex);
T = T(extIndex);
L = L(extIndex);
    
    
    
    
    
    

%**************************************************************
%% SPLITTING METHODS

sbar=findobj('Tag','Statusbar');
tic 
   set(sbar,'String','Status: Calculating with Rotation-Correlation method');drawnow
[phiRC, dtRC, Cmap, FSrc, QTcorRC, Cresult] = ...
    splitRotCorr(Q, T, thiseq.bazi, w,config.maxSplitTime, thiseq.dt); 

set(sbar,'String',['Status: Calculating ' config.splitoption ' Method']);drawnow
[phiSC, dtSC, phiEV, dtEV, inipol,  Ematrix,FSsc, QTcorSC, Eresult] = ...
    splitSilverChan(Q, T, thiseq.bazi, w, thiseq.dt, config.maxSplitTime, config.splitoption, config.inipoloption );




%**************************************************************
%Signal-To-Noise ratio
SNR       = [max(abs(QTcorRC(:,1))) / (2*std(QTcorRC(:,2)));   %SNR_QT on same window after correction (like Restivo & Helffrich,1998) 
             max(abs(QTcorSC(:,1))) / (2*std(QTcorSC(:,2)));   %SNR_QT on same window after correction (like Restivo & Helffrich,1998) 
             max(abs(  xcorr(FSrc(:,2), FSrc(:,1),'coeff')  ));
             max(abs(  xcorr(FSsc(:,2), FSsc(:,1),'coeff')  ))];      

set(sbar,'String',['Status: Calculating confidence regions']);drawnow
         
[errbar_phiRC, errbar_tRC, LevelRC] = geterrorbarsRC(T(w), Cmap, Cresult); 
[errbar_phiSC, errbar_tSC, LevelSC] = geterrorbars(T(w), Ematrix(:,:,1), Eresult(1)); 
[errbar_phiEV, errbar_tEV, LevelEV] = geterrorbars(T(w), Ematrix(:,:,2), Eresult(2)); 

phiRC   = [errbar_phiRC(1)  phiRC   errbar_phiRC(2)];             
dtRC    = [errbar_tRC(1)    dtRC    errbar_tRC(2)];
phiSC   = [errbar_phiSC(1)  phiSC   errbar_phiSC(2)];
dtSC    = [errbar_tSC(1)    dtSC    errbar_tSC(2)];
phiEV   = [errbar_phiEV(1)  phiEV   errbar_phiEV(2)];
dtEV    = [errbar_tEV(1)    dtEV    errbar_tEV(2)];

fprintf(' Phi = %5.1f; %5.1f; %5.1f    dt = %.1f; %.1f; %.1f\n', phiRC(2),phiSC(2),phiEV(2), dtRC(2),dtSC(2), dtEV(2));

%% Assign results field to global variable
% first temporary, since we don't know if results will be used
% Later, within the diagnostic plot, the result may be assigned to the
% permanent eq.results-structure
%
% See also: saveresult.m
    thiseq.tmpresult.phiRC   = phiRC;
    thiseq.tmpresult.dtRC    = dtRC;
    thiseq.tmpresult.phiSC   = phiSC;
    thiseq.tmpresult.dtSC    = dtSC;
    thiseq.tmpresult.phiEV   = phiEV;
    thiseq.tmpresult.dtEV    = dtEV;

    thiseq.tmpresult.inipol  = inipol; 
    thiseq.tmpresult.SNR     = SNR;
    
    thiseq.tmpresult.a       = thiseq.a;
    thiseq.tmpresult.f       = thiseq.f;

    thiseq.tmpresult.remark  = '';  %default remark


%% diagnostic plot
  set(sbar,'String','Status: drawing...');drawnow
val     = get(findobj('Tag','PhaseSelector'),'Value');
if isempty(val)
            val = strmatch(thiseq.SplitPhase, thiseq.phase.Names,'exact');
            val = val(1);   
end
inc     = thiseq.phase.inclination(val);
splitdiagnosticplot(Q, T, extime, L(w), E(w), N(w), inc, thiseq.bazi, thiseq.dt, config.maxSplitTime, inipol,...
        phiRC, dtRC, Cmap,    FSrc, QTcorRC,...
        phiSC, dtSC, Ematrix, FSsc, QTcorSC,...
        phiEV, dtEV, LevelSC, LevelRC, LevelEV, config.splitoption); 
        

    
%% finishing  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
set(sbar,'String',['Status:  calculation time: ' num2str(toc,4) ' seconds'])
    drawnow

    
    
    
    
%% Log file; saving all different results
log = 1; % option for future versions
if log
    DATE  = sprintf('%4.0f.%03.0f',thiseq.date([1 7]));
    fname = [config.savedir, filesep, 'all_results_',config.project(1:end-4),'.log'];
    xst   = exist(fname);
    fid_log  = fopen(char(fname),'a+');
    if fid_log==-1
        errordlg ({'Problems while opening logfile:',fname,' ', 'Please check output directory'})
    else
        if ~xst
            fprintf(fid_log,'All splitting measurements made at station: %s\n',config.stnname);
            fprintf(fid_log,'--------------------------------------------------------------------------------------------------------------------------------------------');
fprintf(fid_log,'\n  date     sta  phase    baz    filter    phi_RC    dt_RC      phi_SC           dt_SC       phi_EV   dt_EV     A       F       OPTION' );
        end
        fseek(fid_log, 0, 'eof'); %go to end of file
fprintf(fid_log,'\n%s  %4s  %5s  %6.2f [%4.2f %3.1f]  %6.2f  %6.2f    %4.0f<%3.0f <%3.0f   %4.1f< %3.1f <%3.1f   %5.1f   %5.1f     %6.1f  %6.1f  %s',...
    DATE, config.stnname, thiseq.SplitPhase, thiseq.bazi, thiseq.filter,...
    thiseq.tmpresult.phiRC(2), thiseq.tmpresult.dtRC(2),...
    thiseq.tmpresult.phiSC,    thiseq.tmpresult.dtSC,...
    thiseq.tmpresult.phiEV(2), thiseq.tmpresult.dtEV(2),...
    thiseq.a, thiseq.f, config.splitoption);
        fclose(fid_log);
    end
end