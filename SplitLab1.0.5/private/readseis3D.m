function out = readseis3D(config,thiseq)
% read three seismograms (eq(i).seisfiles{1:3}) and rotate in 3D
% add to thiseq-structure the fields Amp (E, N, Z, Q, T, L components)
% times vector and dt(sampling rate)
%
% The sesimogramms are shifted by offset time (difference between hypo time
% and beginn of seimogram) and are cut to common times
%
% AW Feb. 2006

%% CHANGES
% 17.02.06 - offset negative for times before hypotime
%          - possible to use startr times other than zero
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%read in
efile = fullfile(config.datadir, thiseq.seisfiles{1});
nfile = fullfile(config.datadir, thiseq.seisfiles{2});
zfile = fullfile(config.datadir, thiseq.seisfiles{3});

s = findobj('Tag','Statusbar'); 
try
    e = rsac(efile);set(s,'String', '  Status:   Reading seismograms ... East');drawnow
    n = rsac(nfile);set(s,'String', '  Status:   Reading seismograms ... East North');drawnow
    v = rsac(zfile);set(s,'String', '  Status:   Reading seismograms ... East North Vertical');drawnow
catch
    e = rsacsun(efile);set(s,'String', '  Status:   Reading seismograms ... East');drawnow
    n = rsacsun(nfile);set(s,'String', '  Status:   Reading seismograms ... East North');drawnow
    v = rsacsun(zfile);set(s,'String', '  Status:   Reading seismograms ... East North Vertical');drawnow
end

%% get SAC header markers:
[A(1), F(1), O(1)] = lh(e, 'A', 'F', 'O');
[A(2), F(2), O(2)] = lh(n, 'A', 'F', 'O');
[A(3), F(3), O(3)] = lh(v, 'A', 'F', 'O');

A = A(A~=-12345);
F = F(F~=-12345);
if isempty(A); A = nan;  F = nan;   end
if isempty(F); A = nan;  F = nan;   end
A = mean(A(:) + thiseq.offset(:));
F = mean(F(:) + thiseq.offset(:));




%% shift time vector
%offset is negativ, if file begins before origin time
offset = floor(thiseq.offset*100)/100;
e(:,1) = e(:,1) + offset(1);
n(:,1) = n(:,1) + offset(2);
v(:,1) = v(:,1) + offset(3);

%% check sampling rate
dt = [mean(diff(e(:,1)))   mean(diff(n(:,1)))   mean(diff(v(:,1)))];
dt = round(dt*1000)/1000;
if length(unique(dt)) > 1 %check if sampling rate is equal
   disp('resampling of seismogram neccesary')
   beep
   [r,d] = rat(max(dt)./dt);
   if any(d~=1),
       disp('ERROR: impossible to handle SAC time vector')
       disp(['   Mean sampling rates (E, N, Z):    [' num2str(1./dt) ']Hz'])
       disp( '   Please check "B" and "E" header entries')
       error('   Cannot treat sampling rate of seismograms')
   end
   e = e(2, 1:r(1):end);
   n = n(2, 1:r(2):end);
   v = v(2, 1:r(3):end);
end
dt=max(dt);

%% times relative to origin time
thestart = max([e(1,1)   n(1,1)   v(1,1)  ])+dt/2;% adding half a sample
theend   = min([e(end,1) n(end,1) v(end,1)])-dt/2;% for excluding accidential overlap

if thestart>theend
    Err =errordlg({['Files do not cover the same time window at earthquake #' num2str(config.db_index)],...
        ' ',thiseq.seisfiles{:},...
        ' ', 'Skipping to next event...'},'Error opening files');
    waitfor(Err)
    out = config.db_index+1;

    return
end


%% synchonize seismograms: cut at times common to all 3 seismograms
indE = find(e(:,1)>thestart & e(:,1)<theend);%FIRST SAC coloumn REPRESENTS TIME VECTOR
indN = find(n(:,1)>thestart & n(:,1)<theend);
indV = find(v(:,1)>thestart & v(:,1)<theend);


% Vectors should be same size, but to be sure, take shortest length
L = min([length(indE) length(indN) length(indV) ]);
e = e( indE(1:L), 2 ); %SECOND SAC coloumn REPRESENTS AMPLITUDE
n = n( indN(1:L), 2 );
v = v( indV(1:L), 2 );


tvec = linspace(thestart, theend, size(e,1));

%% interpolate if neccesary

if ~strcmp('raw', config.resamplingfreq)
    newdt = 1/str2num(config.resamplingfreq);
    if dt ~= newdt
        s = findobj('Tag','Statusbar');
        set(s,'String', sprintf('Status:  Interpolating sampling frequency to %sHz... ', config.resamplingfreq));drawnow

        tvec_old=tvec;
        tvec=thestart:newdt:theend;
        Y  = [e n v];
        Yi = interp1(tvec_old', Y, tvec','linear');
        e  = Yi(:,1);
        n  = Yi(:,2);
        v  = Yi(:,3);
        dt=newdt;
        set(s,'String', sprintf('Status:  Interpolating sampling frequency to %sHz... Done', config.resamplingfreq));drawnow
    end
end
    
%%    % remove mean & trend
    EastAmp  = detrend(e,'constant');
    EastAmp  = detrend(e,'linear');
    NorthAmp = detrend(n,'constant');
    NorthAmp = detrend(n,'linear');
    VertAmp  = detrend(v,'constant');
    VertAmp  = detrend(v,'linear');
    
%% Perform station correction:
a = config.rotation/180*pi;
M = [ cos(a) sin(a);
     -sin(a) cos(a)];
 
New      = M * [EastAmp NorthAmp]';
if config.SwitchEN
    EastAmp  = New(2,:)' * config.signE;
    NorthAmp = New(1,:)' * config.signN;
else
    EastAmp  = New(1,:)' * config.signE;
    NorthAmp = New(2,:)' * config.signN;
end



%% ========================================================================
out = thiseq;

out.Amp.East   = EastAmp;
out.Amp.North  = NorthAmp;
out.Amp.Vert   = VertAmp;
out.Amp.time   =  tvec;
out.dt         = dt;
out.SACpicks   = [A F];



