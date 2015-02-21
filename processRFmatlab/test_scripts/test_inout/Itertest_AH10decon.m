clc;clear;close all;
Stalist='C:\GMT\ahzjsplit\ahzjst.dat';Datapath='F:\ahzjanisotropy\crustal anisotropy\';
[Stations Stalat Stalon]=textread(Stalist,'%4c %f %f',-1);
stanumber=length(Stations);
m=1;
while 1
    if m==stanumber+1
    break,end;
disp([num2str(m) '----' 'station: ' Stations(m,:) ' latitude: ' num2str(Stalat(m)) ' longitude: ' num2str(Stalon(m))]);
m=m+1;
end
Stanum=input('enter the station number: ');
Station=Stations(Stanum,:);stalat=Stalat(Stanum);stalon=Stalon(Stanum);
[event evlat evlon evdep dis bazi rayp]=textread([Datapath Station '\' Station 'ref\' Station 'dislist.dat'],'%s %f %f %f %f %f %f',-1);
EV_num=length(evdep);
%% Loop to calculate RFs by the iterative deconvolution method
for i = 1:EV_num
prefix=['ah10cutsac\' char(event(i,:))];disp(['Event number ' num2str(i) ':' prefix])  % prefix of for 3 components to open
% get file names
Zfile = [ prefix, '.1.sac' ];
Efile = [ prefix, '.3.sac' ];
Nfile = [ prefix, '.2.sac' ];

% Use function to read files in simultaneously
[Eseis, Nseis, Zseis, hdr] = read3seis( Efile, Nfile, Zfile );

% get the times
[t, dt, times, labels] = getTimes(hdr);
nt = hdr.trcLen;

% plot 
%clf
%plot3seis( t, Zseis, t, Nseis, t, Eseis, ['Z'; 'N'; 'E'], times, labels); 

%rotate to ZRT corrdinates
seis = rotateSeisENZtoTRZ( [Eseis, Nseis, Zseis] , bazi(i) );
Rseis = seis(:,2);
Zseis = seis(:,3);

%bandpass
NORD=3;FHP=0.1;FLP=3;
%Rseis=bandpassSeis(Rseis, dt, FHP, FLP ,NORD);
%Zseis=bandpassSeis(Zseis, dt, FHP, FLP ,NORD);

% Receiver function parameters
Shift = 10; %RF starts at 5 s
f0 = 2.0; % pulse width
niter = 1000;  % number iterations
minderr = 0.001;  % stop when error reaches limit

% Make receiver function
[RadialRF, RMS,it_num] = makeRFitdecon_la( Rseis, Zseis, dt, nt, Shift, f0, ...
				 niter, minderr);

% get time for RF
time = - Shift  + dt*(0:1:nt-1);

% plot RF
%clf;
%h1 = plot(time,RadialRF,'k'); hold on;
%set(gca,'xlim',[-5 20])
%pause

% plot the RMS from the iterations
%figure(2); clf;
%h2 = semilogy(RMS,'.k'); hold on;
%legend([ h2 ], 'L&A - matlab')
%xlabel('Iteration Number')
%ylabel('Scaled Sum Sq Error')
% output RF data
% base directory for output
odir = fullfile([Station 'ref']);RFlength=length(RadialRF);
if( ~exist( odir , 'dir') )
    mkdir( odir ); end

filename = fullfile(odir, [char(event(i,:)) '_R_iter.dat']);
fid=fopen(filename,'w+');
for ii = 1:RFlength
    fprintf(fid,'%f\n',RadialRF(ii));    
end
fclose(fid);
%output iteration number
filename1 = fullfile(odir, [Station 'iternumber.dat']);
fid1=fopen(filename1,'a+');
fprintf(fid1,'%s %u %f\n',char(event(i,:)),it_num,RMS(it_num));
fclose(fid1);
%clf
fprintf('----------------------------------------------------------------------------------------------\n');
end