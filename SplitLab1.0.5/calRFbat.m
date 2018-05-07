function calRFbat
global  config eq rf

rf = struct();


for i=1:length(eq)
    %    fprintf(' %s -- analysing event  %s:%4.0f.%03.0f (%.0f/%.0f) --\n',...
    %     datestr(now,13) , config.stnname, thiseq.date(1), thiseq.date(7),config.db_index, length(eq));
    str  = ['Calculate ' char(dname(eq(i).date(1), eq(i).date(2), eq(i).date(3), eq(i).date(4), eq(i).date(5), eq(i).date(6)))];
    head = ['done... Do ' num2str(i) 'th of' num2str(length(eq))];
    workbar(i/length(eq), str, head)
    
    efile = fullfile(config.datadir, eq(i).seisfiles{1});
    nfile = fullfile(config.datadir, eq(i).seisfiles{2});
    zfile = fullfile(config.datadir, eq(i).seisfiles{3});
    if ~exist(efile,'file')||~exist(nfile,'file')||~exist(zfile,'file')
        errordlg({'Seismograms not found!','Please check data directory',efile,nfile,zfile},'File I/O Error')
        continue
    end
    
    try
        out=readseis3D_forRF(config,i);
    catch
        rf(i).RadialRF_f1 = [];
        continue
    end


o         = eq(i).offset(1);
extbegin  = floor( (eq(i).phase.ttimes(1) - config.extime_before - o) / out.dt);
extfinish = floor( (eq(i).phase.ttimes(1) + config.extime_after - o) / out.dt); %index of last element
extIndex  = extbegin:extfinish;%create vector of indices to elements of extended selection window
RFlength  = length(extIndex);


if length(out.Amp.East)<extfinish
    continue
end
E =  out.Amp.East;
N =  out.Amp.North;
Z =  out.Amp.Vert;

ny    = 1/(2*out.dt);%nyquist freqency of seismogramm
n     = 3; %filter order

f1 = 0.1;
f2 = 2;
f3 = 0.06;
f4 = 0.03;

[b1,a1]  = butter(n, [f4 f2]/ny);
[b2,a2]  = butter(n, [f3 f2]/ny);
[b3,a3]  = butter(n, [f1 f2]/ny);

 
    E = detrend(E,'constant');
    E = detrend(E,'linear');
    N = detrend(N,'constant');
    N = detrend(N,'linear');
    Z = detrend(Z,'constant');
    Z = detrend(Z,'linear');
        
    E1 = filtfilt(b1,a1,E); 
    N1 = filtfilt(b1,a1,N);
    Z1 = filtfilt(b1,a1,Z);
 
    E2 = filtfilt(b2,a2,E); 
    N2 = filtfilt(b2,a2,N);
    Z2 = filtfilt(b2,a2,Z);
 
    E3 = filtfilt(b3,a3,E); 
    N3 = filtfilt(b3,a3,N);
    Z3 = filtfilt(b3,a3,Z);
    
    seis1 = rotateSeisENZtoTRZ( [E1, N1, Z1] , eq(i).bazi );
    seis2 = rotateSeisENZtoTRZ( [E2, N2, Z2] , eq(i).bazi );
    seis3 = rotateSeisENZtoTRZ( [E3, N3, Z3] , eq(i).bazi );

    
    T1 = seis1(:,1);
    T1 = T1(extIndex);
    R1 = seis1(:,2);
    R1 = R1(extIndex);
    Z1 = seis1(:,3);
    Z1 = Z1(extIndex);

     
    snrbegin  = floor( (eq(i).phase.ttimes(1) - 50 - o) / out.dt);
    snrfinish = floor( (eq(i).phase.ttimes(1) + 50 - o) / out.dt);
    snro = floor( (eq(i).phase.ttimes(1) - o) / out.dt);
    In  = snrbegin:snro;
    I   = snro:snrfinish;
    T = seis1(:,1);
    R = seis1(:,2);
    Z = seis1(:,3);
    snrR = snr(R(I),R(In));
    snrT = snr(T(I),T(In));
    snrZ = snr(Z(I),Z(In));
    
    if snrR < config.snrgate || snrZ < config.snrgate
        rf(i).RadialRF_f1 = [];
        continue
    end
    
    T2 = seis2(:,1);
    T2 = T2(extIndex);
    R2 = seis2(:,2);
    R2 = R2(extIndex);
    Z2 = seis2(:,3);
    Z2 = Z2(extIndex);

    T3 = seis3(:,1);
    T3 = T3(extIndex);
    R3 = seis3(:,2);
    R3 = R3(extIndex);
    Z3 = seis3(:,3);
    Z3 = Z3(extIndex);
   


% Shift = 10; %RF starts at 10 s
% f0 = 2.0; % pulse width
niter = 400;  % number iterations
minderr = 0.001;  % stop when error reaches limit

% fprintf([num2str(i) 'th---\n'])
if config.iter == 1
[RadialRF1, RMS_R,it_num_R] = makeRFitdecon_la( R1, Z1, out.dt, RFlength, config.extime_before, config.f0, ...
				 niter, minderr);
[TransverseRF1, RMS_T,it_num_T] = makeRFitdecon_la( T1, Z1, out.dt, RFlength, config.extime_before, config.f0, ...
				 niter, minderr);

[RadialRF2, RMS_R,it_num_R] = makeRFitdecon_la( R2, Z2, out.dt, RFlength, config.extime_before, config.f0, ...
				 niter, minderr);
[TransverseRF2, RMS_T,it_num_T] = makeRFitdecon_la( T2, Z2, out.dt, RFlength, config.extime_before, config.f0, ...
				 niter, minderr);

[RadialRF3, RMS_R,it_num_R] = makeRFitdecon_la( R3, Z3, out.dt, RFlength, config.extime_before, config.f0, ...
				 niter, minderr);
[TransverseRF3, RMS_T,it_num_T] = makeRFitdecon_la( T3, Z3, out.dt, RFlength, config.extime_before, config.f0, ...
				 niter, minderr);
else
[RadialRF1, RMS_R,it_num_R] = makeRFwater_ammon( R1, Z1, config.extime_before, out.dt, RFlength, ...
				 0.01, config.f0, 0);
[TransverseRF1, RMS_T,it_num_T] =makeRFwater_ammon( T1, Z1, config.extime_before, out.dt, RFlength, ...
				 0.01, config.f0, 0);

[RadialRF2, RMS_R,it_num_R] = makeRFwater_ammon( R2, Z2, config.extime_before, out.dt, RFlength, ...
				 0.01, config.f0, 0);
[TransverseRF2, RMS_T,it_num_T] = makeRFwater_ammon( T2, Z2, config.extime_before, out.dt, RFlength, ...
				 0.01, config.f0, 0);

[RadialRF3, RMS_R,it_num_R] = makeRFwater_ammon( R3, Z3, config.extime_before, out.dt, RFlength, ...
				 0.01, config.f0, 0);
[TransverseRF3, RMS_T,it_num_T] = makeRFwater_ammon( T3, Z3, config.extime_before, out.dt, RFlength, ...
				 0.01, config.f0, 0);    
end

             
rf(i).RadialRF_f1 = RadialRF1;
rf(i).TransverseRF_f1 = TransverseRF1;
rf(i).RadialRF_f2 = RadialRF2;
rf(i).TransverseRF_f2 = TransverseRF2;
rf(i).RadialRF_f3 = RadialRF3;
rf(i).TransverseRF_f3 = TransverseRF3;
rf(i).RMS_R = RMS_R;
rf(i).RMS_T = RMS_T;
rf(i).it_num_R = it_num_R;
rf(i).it_num_T = it_num_T;
rf(i).a = eq(i).phase.ttimes(1);
rf(i).f1 = f1;
rf(i).f2 = f2;
rf(i).f3 = f3;
rf(i).f4 = f4;
rf(i).T1 = T1;
rf(i).R1 = R1;
rf(i).Z1 = Z1;
rf(i).T2 = T2;
rf(i).R2 = R2;
rf(i).Z2 = Z2;
rf(i).T3 = T3;
rf(i).R3 = R3;
rf(i).Z3 = Z3;
rf(i).dt = out.dt;
rf(i).seisfile = dname(eq(i).date(1), eq(i).date(2), eq(i).date(3), eq(i).date(4), eq(i).date(5), eq(i).date(6));
rf(i).phase = eq(i).phase.Names{1};
rf(i).lat = eq(i).lat;
rf(i).lon = eq(i).long;
rf(i).depth = eq(i).depth;
rf(i).dis = eq(i).dis;
rf(i).bazi = eq(i).bazi;
rf(i).Mw = eq(i).Mw;
rf(i).RFlength = RFlength;
rf(i).snrR = snrR;
rf(i).snrT = snrT;
rf(i).snrZ = snrZ;
end

rfview = findobj('Tag','RFButton');
set(rfview,'Enable','on');
% ind=[];
% for i=1:length(rf)
%     if isempty(rf(i).dt)
%         
%         ind=[ind,i];
%     end
% end
% rf(ind)=[];
% 
% baz=zeros(length(rf),1);
% for k=1:length(baz)
%     baz(k)=rf(k).bazi;
% end
% 
% [~,index]=sort(baz,1);
% rf=rf(index);
% for ii = 1:length(rf)
%     rf(ii).index = ii;
% end

return
