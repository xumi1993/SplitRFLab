function writeSAC(ofname, SAChdr, seis)
% Write a sac file given the header and seis data
%
% writeSAC(ofname, SAChdr, seis)
%
% write SAC format seis (based on Zhegang Peng's wtSAC.m)
%
% IN: 
% ofname = (string) filename to write to
% SAChdr = (structure) sac header - see sachdr for fields
% seis = seismogram amplitudes
%
% 

% Open the output file
aa=fopen(ofname,'w+');
if aa<0
  ofname
  return;
end

% make all default values
hd1 = -12345.0*ones(70,1);
hd2 = -12345*ones(40,1);

% make 24 8 character header, fill with spaces
for i=1:24,
  hd3((i-1)*8+1:i*8) = '        ';
end


hd1(1) = SAChdr.times.delta; 
hd1(2) = min(seis); % depmin
hd1(3) = max(seis); % depmax
hd1(4) = SAChdr.scale;
% odelta

hd1(6) = SAChdr.times.b;
hd1(7) = SAChdr.times.e;
hd1(8) = SAChdr.times.o;
hd1(9) = SAChdr.times.a;
% 10 is internal

hd1(11:20) = [ SAChdr.times.atimes(1:10).t ];

% f
hd1(22:31) = SAChdr.response;

hd1(32) = SAChdr.station.stla; % station latitude
hd1(33) = SAChdr.station.stlo; % station longitude
hd1(34) = SAChdr.station.stel; % station elevation
hd1(35) = SAChdr.station.stdp; % station depth if below surface

hd1(36) = SAChdr.event.evla; % event info
hd1(37) = SAChdr.event.evlo;
hd1(38) = SAChdr.event.evel;
hd1(39) = SAChdr.event.evdp; % event depth
hd1(40) = SAChdr.event.mag;

% user seis 
for i=41:50, 
  hd1(i) = SAChdr.user(i-40).data;
end

hd1(51) = SAChdr.evsta.dist;
hd1(52) = SAChdr.evsta.az;
hd1(53) = SAChdr.evsta.baz; % back azimuth
hd1(54) = SAChdr.evsta.gcarc; % back azimuth
% 55 is internal

% 56 is internal
hd1(57) = mean(seis); % depmen
hd1(58) = SAChdr.station.cmpaz; % cmpaz
hd1(59) = SAChdr.station.cmpinc; % cmpinc
% 60 xmin - spectral files only 

% 61 xmax - spectral files only 
% ymin - spectral files only 
% ymax - spectral files only 
% 64 - 70: unused

% integers
hd2(1) = SAChdr.event.nzyear;
hd2(2) = SAChdr.event.nzjday;
hd2(3) = SAChdr.event.nzhour;
hd2(4) = SAChdr.event.nzmin;
hd2(5) = SAChdr.event.nzsec;

hd2(6) = SAChdr.event.nzmsec;
hd2(7) = 6;	% version number
% norid
% nevid
%hd2(10) = SAChdr.trcLen; % number of points
hd2(10) = numel(seis); % number of points

% 11 is internal
hd2(12) = SAChdr.llnl.nwfid; % nwfid
% nxsize
% nysize
% 15: unused

hd2(16) = 1;	% iftype
hd2(17) = SAChdr.descrip.idep; % units of dependent variable
hd2(18) = SAChdr.descrip.iztype; % origin time type iztype
% 19: unused 
% iinst

%21: istreg
%ievreg
%ievtyp
%iqual
%isynth

%26: imagtyp
%imagsrc
% 28 - 35: unused

hd2(36) = 1; % leven
% lpspol
% lovrok
% lcalda
% 40: unused

stnname = sprintf('%-8s',SAChdr.station.kstnm);
hd3(1:8)=stnname(1:8);

kevnm = sprintf('%-8s',SAChdr.event.kevnm);
hd3(9:24)=kevnm(1:16);

% hd3(25:32) % khole

ko = sprintf('%-8s',SAChdr.times.k0);
hd3(33:40) = ko(1:8);

ka = sprintf('%-8s',SAChdr.times.ka);
hd3(41:48) = ka(1:8);

for i=1:10,
  kt = sprintf('%-8s',SAChdr.times.atimes(i).label);
  hd3(41+i*8:48+i*8) = kt(1:8);
end

% hd(129:136) % kf

for i=1:3,
  kuser = sprintf('%-8s',SAChdr.user(i).label);
  hd3(129+i*8:136+i*8)=kuser(1:8);
end

kcmpnm = sprintf('%-8s',SAChdr.station.kcmpnm);
hd3(161:168) = kcmpnm(1:8);

ntwkname = sprintf('%-8s',SAChdr.station.knetwk);
hd3(169:176) = ntwkname(1:8);


% Finally write

fwrite(aa, hd1(1:70), 'single');
fwrite(aa, hd2(1:40), 'int');
fwrite(aa, hd3(1:192),'char');

fwrite(aa, seis,'single');
fclose(aa);

return