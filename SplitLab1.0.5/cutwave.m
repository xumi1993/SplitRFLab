function cutwave
global thiseq config

if ispc
OUT_path = [config.cutdir '\' config.stnname];%path of cut out data
else
OUT_path = [config.cutdir '/' config.stnname];%path of cut out data
end


ny = round(1 / thiseq.dt / 2); %nyquist frequency
f1 = thiseq.filter(1);
f2 = thiseq.filter(2);

o         = thiseq.Amp.time(1);%common offset of all files after hypotime
if ~isfield(thiseq, 'a')
    extbegin = floor( (thiseq.phase.ttimes(1) - config.extime_before - o) / thiseq.dt);
    extfinish = floor( (thiseq.phase.ttimes(1) + config.extime_after - o) / thiseq.dt);
else
    extbegin  = floor( (thiseq.a - config.extime_before - o) / thiseq.dt); %index of first element of amplitude verctor of the selected time window
    extfinish = floor( (thiseq.a + config.extime_after - o) / thiseq.dt); %index of last element
end
extIndex  = extbegin:extfinish;%create vector of indices to elements of extended selection window

switch thiseq.system
    case 'ENV'
        ch1 =  thiseq.Amp.East(extIndex);
        ch2 =  thiseq.Amp.North(extIndex);
        ch3 =  thiseq.Amp.Vert(extIndex);
        nch1 = 'E';
        nch2 = 'N';
        nch3 = 'Z';
    case 'LTQ'
        ch1 = thiseq.Amp.Radial(extIndex)';
        ch2 = thiseq.Amp.Transv(extIndex)';
        ch3 = thiseq.Amp.Ray(extIndex)';
        nch1 = 'Q';
        nch2 = 'T';
        nch3 = 'L';
    case 'RTZ'
        ch1 = thiseq.Amp.R(extIndex);
        ch2 = thiseq.Amp.T(extIndex);
        ch3 = thiseq.Amp.Z(extIndex);
        nch1 = 'R';
        nch2 = 'T';
        nch3 = 'Z';
end
%% Do filter
    if f1 > 0  &&  f2 < inf
        % bandpass
        [b,a]  = butter(3, [f1 f2]/ny);

    elseif f1==0 &&  f2 < inf
        %lowpass
        [b,a]  = butter(3, [f2]/ny,'low');

    elseif f1>0 &&  f2 == inf
        %highpass
        [b,a]  = butter(3, [f1]/ny, 'high');
    end

    ch1 = detrend(ch1,'linear');ch1 = detrend(ch1,'constant');
    ch2 = detrend(ch2,'linear');ch2 = detrend(ch2,'constant');
    ch3 = detrend(ch3,'linear');ch3 = detrend(ch3,'constant');

% Taper
  len  = round(length(ch1)*.03); %taper length is 3% of total seismogram length
  nn   = 1:len;
  nn2  = (length(ch1)-len+1):length(ch1);
  x    = linspace(pi, 2*pi, len);
taper  = 0.5 * (cos(x')+1);
taper2 = fliplr(taper);

% taper at begin           taper at end of seismogram
ch1(nn) = ch1(nn).*taper;    ch1(nn2) = ch1(nn2).*taper2;
ch2(nn) = ch2(nn).*taper;    ch2(nn2) = ch2(nn2).*taper2;
ch3(nn) = ch3(nn).*taper;    ch3(nn2) = ch3(nn2).*taper2;

ch1 = filtfilt(b,a,ch1); 
ch2 = filtfilt(b,a,ch2);
ch3 = filtfilt(b,a,ch3);

%% Save
time = -config.extime_before:thiseq.dt:config.extime_after;
Ev_para = taupTime('iasp91',thiseq.depth,thiseq.SplitPhase,'sta',[config.slat,config.slong],'evt',[thiseq.lat,thiseq.long]);   
Ev_para = srad2skm(Ev_para(1).rayParam);  
if config.issac
    if( ~exist( OUT_path , 'dir') )
         mkdir( OUT_path ); end
    channel = [ch1,ch2,ch3];
    cname = [nch1,nch2,nch3];
for m=1:3
    %access structure using dynamic filed names
    tmp  = bsac(time,channel(:,m));
    tmp = ch(tmp,...
        'DELTA',  mean(diff(time)),...
        'O',      0,...
        'B',      time(1),...
        'E',      time(end),...
        'A',      thiseq.a,...
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
    fname = [thiseq.seisfiles{1}(config.yy:config.ss) '_' cname(m) '.sac'];
    outname = fullfile(OUT_path,fname);
    wsac(outname, tmp)
end
else
     if( ~exist( OUT_path , 'dir') )
         mkdir( OUT_path ); end
     fiddataT = fopen(fullfile(OUT_path,[thiseq.seisfiles{1}(config.yy:config.ss) '_' nch1 '_' config.stnname '.dat']),'w+'); 
     fprintf(fiddataT,'%20.19f\n',ch1);
     fclose(fiddataT);
     
     fiddataR = fopen(fullfile(OUT_path,[thiseq.seisfiles{1}(config.yy:config.ss) '_' nch2 '_' config.stnname '.dat']),'w+'); 
     fprintf(fiddataR,'%20.19f\n',ch2);
     fclose(fiddataR);
     
     fiddataZ = fopen(fullfile(OUT_path,[thiseq.seisfiles{1}(config.yy:config.ss) '_' nch3 '_' config.stnname '.dat']),'w+'); 
     fprintf(fiddataZ,'%20.19f\n',ch3);
     fclose(fiddataZ);
  
     fid_finallist = fopen(fullfile(OUT_path,[config.stnname 'finallist.dat']),'a+');
     fprintf(fid_finallist,'%s %s %f %f %f %f %f %f %f %f\n',thiseq.seisfiles{1}(config.yy:config.ss),thiseq.SplitPhase,thiseq.lat,thiseq.long,thiseq.depth,thiseq.dis,thiseq.bazi,Ev_para,thiseq.Mw,config.f0);
     fclose(fid_finallist);
end
disp(['Saving ' thiseq.seisfiles{1}(config.yy:config.ss) ' Succesful!!!'])
