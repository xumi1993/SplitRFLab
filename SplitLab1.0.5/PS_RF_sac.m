function PS_RF_sac
% make your own function for splitlab
%
% this takes theselected time window performs a operation that you define
% and than gives an example of how to access the final results structure
% 

%% FIRST, make global variables visible to our template.
% config   - contains information on your configuration (directories, etc)
% eq       - is the structure of all earthquake parameters
% thiseq   - contains the paramters of this earthquake (very smart), plus 
%            additional temporary information, eg in thiseq.Amp the amplitude
%            vectors are saved 
global  config eq thiseq 
%print info to standard output
fprintf(' %s -- analysing event  %s:%4.0f.%03.0f (%.0f/%.0f) --\n',...
    datestr(now,13) , config.stnname, thiseq.date(1), thiseq.date(7),config.db_index, length(eq));


  
%% extend selection window
%some calculations require an extended tim window to perferm properly
% so this is what we do here
% extime_before    = 10 ; 
% extime_after    = 120 ; 
o         = thiseq.Amp.time(1);%common offset of all files after hypotime

if ~isfield(thiseq, 'a')
    A = thiseq.phase.ttimes(1);
    extbegin = floor( (thiseq.phase.ttimes(1) - config.extime_before - o) / thiseq.dt);
    extfinish = floor( (thiseq.phase.ttimes(1) + config.extime_after - o) / thiseq.dt);
else
    A =  thiseq.a;
    extbegin  = floor( (thiseq.a - config.extime_before - o) / thiseq.dt); %index of first element of amplitude verctor of the selected time window
    extfinish = floor( (thiseq.a + config.extime_after - o) / thiseq.dt); %index of last element
end
extIndex  = extbegin:extfinish;%create vector of indices to elements of extended selection window
RFlength = length(extIndex);
% now find indices of selected window, but this time 
% relative to extended window, defined above

%ex = floor(extime/thiseq.dt) ;
%w  = (ex+1):(length(extIndex)-ex);


%% OK, now we can define our seismogram components windows
E =  thiseq.Amp.East(extIndex);
N =  thiseq.Amp.North(extIndex);
Z =  thiseq.Amp.Vert(extIndex);

Q = thiseq.Amp.Radial(extIndex)';
T = thiseq.Amp.Transv(extIndex)';
L = thiseq.Amp.Ray(extIndex)';


%% Filtering
% the seismogram components are not yet filtered
% define your filter here.
% the selected corner frequncies are stored in the varialbe "thiseq.filter"
% 
ny    = 1/(2*thiseq.dt);%nyquist freqency of seismogramm
n     = 3; %filter order

f1 = thiseq.filter(1);
f2 = thiseq.filter(2);
if f1==0 && f2==inf %no filter
    % do nothing
    % we leave the seismograms untouched
else
    if f1 > 0  &&  f2 < inf
        % bandpass
        [b,a]  = butter(n, [f1 f2]/ny);
    elseif f1==0 &&  f2 < inf
        %lowpass
        [b,a]  = butter(n, [f2]/ny,'low');

    elseif f1>0 &&  f2 == inf
        %highpass
        [b,a]  = butter(n, [f1]/ny, 'high');
    end
    Q = filtfilt(b,a,Q); %Radial     (Q) component in extended time window
    T = filtfilt(b,a,T); %Transverse (T) component in extended time window
    L = filtfilt(b,a,L); %Vertical   (L) component in extended time window
    
    E = filtfilt(b,a,E); 
    N = filtfilt(b,a,N);
    Z = filtfilt(b,a,Z);
end

%% do some detrending of extended time window
    E = detrend(E,'constant');
    E = detrend(E,'linear');
    N = detrend(N,'constant');
    N = detrend(N,'linear');
    Z = detrend(Z,'constant');
    Z = detrend(Z,'linear');
    
    Q = detrend(Q,'constant');
    Q = detrend(Q,'linear');
    T = detrend(T,'constant');
    T = detrend(T,'linear');
    L = detrend(L,'constant');
    L = detrend(L,'linear');
    
    seis = rotateSeisENZtoTRZ( [E, N, Z] , thiseq.bazi );
T = seis(:,1);
R = seis(:,2);
Z = seis(:,3);

%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%%                P U T     Y O U R    C O D E    H E R E
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% here you can start with your own coding;
% you should make use of the global "config" and "thiseq" variable to get
% information about the station (lat, long) and earthquake (bazi, depth).
%
% any of your results may be stored temporarily in a variable within thiseq
% something like     
%    thiseq.MyVariable=[max(E) max(N) max(Z)];

%% Receiver function parameters
RFlength = length(extIndex);
% Shift = 10; %RF starts at 10 s
% f0 = 2.0; % pulse width
niter = 400;  % number iterations
minderr = 0.001;  % stop when error reaches limit

% Make receiver function
% seis = rotateSeisENZtoTRZ( [E, N, Z] , thiseq.bazi );
% T = seis(:,1);
% R = seis(:,2);
% Z = seis(:,3);
[thiseq.RadialRF, thiseq.RMS_R,thiseq.it_num_R] = makeRFitdecon_la( R, Z, thiseq.dt, RFlength, config.extime_before, config.f0, ...
				 niter, minderr);
[thiseq.TransverseRF, thiseq.RMS_T,thiseq.it_num_T] = makeRFitdecon_la( T, Z, thiseq.dt, RFlength, config.extime_before, config.f0, ...
				 niter, minderr);
%plot RF
time = - config.extime_before  + thiseq.dt*(0:1:RFlength-1);
figure(10);
% set(figure(10),'position',[200 400 1000 800]);
%subplot(3,1,1);plot(time,E,'k');
%subplot(3,1,2);plot(time,N,'k');
%subplot(3,1,3);plot(time,Z,'k');
%pause
plot(time,thiseq.RadialRF,'k','LineWidth',2.0);hold on;
plot(time,thiseq.TransverseRF);hold on
plot(xlim,[0 0],'g--');
set(gca,'xlim',[-5 30],'xtick',(0:2:30),'Xgrid','on')
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%%              R E S U L T   S A V E   T E M P L A T E
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% assume you stored your output in the global variable "thiseq.MyVariable"
% Then you pose a question, if the user wants to save this result (see  the 
% Matlab function QUESTDLG). We have to transmit this result now from temporary
% thiseq to the permanent project variable "eq"
% the index of thiseq in the permanent eq structure is given by the varible
% thiseq.index (very smart...)
%
%OUT_path = ['/Volumes/LaCie/YN.RFunction/RFresult/' config.stnname];%path of PRFs
%OUT_path1 = ['/Volumes/LaCie/YN.RFunction/RFcutoutdata/' config.stnname];%path of cut out data
if ispc
OUT_path = [config.RFdatapath '\' config.stnname];%path of PRFs
OUT_path1 = [config.cutdir '\' config.stnname];%path of cut out data
else
OUT_path = [config.RFdatapath '/' config.stnname];%path of PRFs
OUT_path1 = [config.cutdir '/' config.stnname];%path of cut out data
end


button = MFquestdlg( [ 0.4 , 0.22 ] ,'Do you want to keep the result?','PS_RecFunc',  ...
    'Yes','No','Yes');
if strcmp(button, 'Yes')
    Ev_para = taupTime('iasp91',thiseq.depth,thiseq.SplitPhase,'sta',[config.slat,config.slong],'evt',[thiseq.lat,thiseq.long]);   
    Ev_para = srad2skm(Ev_para(1).rayParam); 
    
    if( ~exist( OUT_path , 'dir') )
        mkdir( OUT_path ); end
    thisrf = [thiseq.RadialRF',thiseq.TransverseRF'];
    cname = ['R','T'];
for m=1:2
    %access structure using dynamic filed names
    tmp  = bsac(time,thisrf(:,m));
    tmp = ch(tmp,...
        'DELTA',  mean(diff(time)),...
        'O',      0,...
        'B',      time(1),...
        'E',      time(end),...
        'A',      A,...
        'NPTS',   length(time),...
        'KSTNM',  config.stnname,...
        'KNETWK', config.netw,...
        'STLA',   config.slat,...
        'STLO',   config.slong,...
        'KCMPNM', cname(m),...
        'EVLA',   thiseq.lat,...
        'EVLO',   thiseq.long,...
        'EVDP',   thiseq.depth,...
        'MAG',    thiseq.Mw,...
        'BAZ',    thiseq.bazi,...
        'GCARC',  thiseq.dis,...
        'IZTYPE', 11,...      %'IO'; reference time is hypo time
        'NZYEAR', thiseq.date(1),...
        'NZJDAY', thiseq.date(7),...
        'NZHOUR', thiseq.date(4),...
        'NZMIN',  thiseq.date(5),...
        'NZSEC',  floor(thiseq.date(6)),...
        'T1',     0,... 
        'KT1',    thiseq.SplitPhase,...
        'USER0',  Ev_para,...
        'KUSER0', 'Ray para',...
        'USER1',  config.f0,...
        'KUSER0', 'G fator',...
        'NZMSEC', round((thiseq.date(6) - floor(thiseq.date(6)))*1000));
    fname = [dname(thiseq.date(1),thiseq.date(2),thiseq.date(3),thiseq.date(4),thiseq.date(5),thiseq.date(6)) '_' thiseq.SplitPhase '_' cname(m) '.sac'];
    outname = fullfile(OUT_path,fname);
    wsac(outname, tmp)
end

%%     cut out data
    if( ~exist( OUT_path1 , 'dir') )
        mkdir( OUT_path1 ); end
    thisdat = [R,T,Z];
    cname = ['R','T','Z'];
for m=1:3
    %access structure using dynamic filed names
    tmp  = bsac(time,thisdat(:,m));
    tmp = ch(tmp,...
        'DELTA',  mean(diff(time)),...
        'O',      0,...
        'B',      time(1),...
        'E',      time(end),...
        'A',      A,...
        'NPTS',   length(time),...
        'KSTNM',  config.stnname,...
        'KNETWK', config.netw,...
        'STLA',   config.slat,...
        'STLO',   config.slong,...
        'KCMPNM', cname(m),...
        'EVLA',   thiseq.lat,...
        'EVLO',   thiseq.long,...
        'EVDP',   thiseq.depth,...
        'MAG',    thiseq.Mw,...
        'BAZ',    thiseq.bazi,...
        'GCARC',  thiseq.dis,...
        'IZTYPE', 11,...      %'IO'; reference time is hypo time
        'NZYEAR', thiseq.date(1),...
        'NZJDAY', thiseq.date(7),...
        'NZHOUR', thiseq.date(4),...
        'NZMIN',  thiseq.date(5),...
        'NZSEC',  floor(thiseq.date(6)),...
        'T1',     0,... 
        'KT1',    thiseq.SplitPhase,...
        'USER0',  Ev_para,...
        'KUSER0', 'Ray parameter',...
        'NZMSEC', round((thiseq.date(6) - floor(thiseq.date(6)))*1000));
    fname = [dname(thiseq.date(1),thiseq.date(2),thiseq.date(3),thiseq.date(4),thiseq.date(5),thiseq.date(6)) '_RFdata_' cname(m) '.sac'];
    outname = fullfile(OUT_path1,fname);
    wsac(outname, tmp)
end

          
     close(figure(10));     
else
    clear('thiseq.RadialRF','thiseq.TransverseRF', 'thiseq.RMS_R','thiseq.it_num_R', 'thiseq.RMS_T','thiseq.it_num_T');close(figure(10));
end

end
