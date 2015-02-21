function [SAChdr]=sachdr(head1, head2, head3)
% From the output of sac.m generate a single sac header structure
%
%function [SAChdr]=sachdr(head1, head2, head3)
% Read from the output header of one single SAC format file and generate 
% the SAChdr structure array contains the following elements:
%    times
%    station
%    event
%    user
%    descrip
%    evsta
%    llnl
%    response
%    data

%Most of these elements are themselves structures and their members
%are as follows:
%times	station	event	user	 descrip  evsta	llnl		data	
%-----	-------	-----	------   -------  -----	----		----
%delta	stla	evla	data(10) iftype   dist	xminimum	trcLen	
%b	stlo	evlo	label(3) idep     az	xmaximum	scale
%e	stel	evel		 iztype   baz	yminimum
%o	stdp	evdp		 iinst    gcarc	ymaximum
%a	cmpaz	nzyear		 istreg		norid
%t0	cmpinc	nzjday		 ievreg		nevid
%t1	kstnm	nzhour		 ievtyp		nwfid
%t2	kcmpnm	nzmin		 iqual		nxsize
%t3	knetwk	nzsec		 isynth		nysize
%t4		nzmsec
%t5		kevnm
%t6		mag
%t7		imagtyp
%t8		imagsrc
%t9
%f
%k0
%ka
%kt1
%kt2
%kt3
%kt4
%kt5
%kt6
%kt7
%kt8
%kt9
%kf

%response is a 10-element array, and trcLen is a scalar. Thus, to 
%reference the begin time you would write:
%SAChdr.times.b 

% Note: The above data structure is copied from the SAC2000 mat 
% reference.

% Function called: sac.m
% Written by Zhigang Peng, USC
% Updated Sun Jul 29 19:04:20 PDT 2001

%[head1, head2, head3, data]=sac(filename);

% SAChdr.times

SAChdr.times.delta   = head1(1,1); % sample interval
SAChdr.times.b   = head1(2,1); % time of first sample
SAChdr.times.e   = head1(2,2); % time of last sample
SAChdr.times.o   = head1(2,3); % origin time 
SAChdr.times.a   = head1(2,4); % time of initial arrival (usually P)

% Arrival times
for i=1:5,
  SAChdr.times.atimes(i).t = head1(3,i); % t0 -- t4
end
for i=1:5,
  SAChdr.times.atimes(i+5).t = head1(4,i); % t5--t9
end

% Labels for arrival times
SAChdr.times.k0  = char(head3(2,9:16));
SAChdr.times.ka  = char(head3(2,17:24));
SAChdr.times.atimes(1).label = char(head3(3,1:8)); % kt0
SAChdr.times.atimes(2).label = char(head3(3,9:16));
SAChdr.times.atimes(3).label = char(head3(3,17:24));
SAChdr.times.atimes(4).label = char(head3(4,1:8));
SAChdr.times.atimes(5).label = char(head3(4,9:16));
SAChdr.times.atimes(6).label = char(head3(4,17:24));
SAChdr.times.atimes(7).label = char(head3(5,1:8));
SAChdr.times.atimes(8).label = char(head3(5,9:16));
SAChdr.times.atimes(9).label = char(head3(5,17:24));
SAChdr.times.atimes(10).label = char(head3(6,1:8)); % kt9
SAChdr.times.kf = char(head3(6,9:16));

% SAChdr.station
SAChdr.station.stla = head1(7,2); % latitude
SAChdr.station.stlo = head1(7,3); % longitude
SAChdr.station.stel = head1(7,4); % elevation
SAChdr.station.stdp = head1(7,5); % depth
SAChdr.station.cmpaz = head1(12,3); % component azimuth
SAChdr.station.cmpinc = head1(12,4); % component inclination
SAChdr.station.kstnm = char(head3(1,1:8)); % station name
SAChdr.station.kcmpnm = char(head3(7,17:24)); % component name
SAChdr.station.knetwk = char(head3(8,1:8)); % network name

% SAChdr.event
SAChdr.event.evla = head1(8,1); % latitude
SAChdr.event.evlo = head1(8,2); % longitude
SAChdr.event.evel = head1(8,3); % elevation 
SAChdr.event.evdp = head1(8,4); % depth
SAChdr.event.nzyear = head2(1,1); % year
SAChdr.event.nzjday = head2(1,2); % julian day
SAChdr.event.nzhour = head2(1,3); % hour
SAChdr.event.nzmin = head2(1,4); % min
SAChdr.event.nzsec = head2(1,5); % second
SAChdr.event.nzmsec = head2(2,1); % milisecond
SAChdr.event.kevnm = char(head3(1,9:24)); % event name
SAChdr.event.mag = head1(8,5); % magnitude
SAChdr.event.imagtyp = []; %
SAChdr.event.imagsrc = [];

% SAChdr.user
i1=1;
for i=9:10
  for j=1:5,
    SAChdr.user(i1).data = head1(i,j);
    i1 = i1+1;
  end
end

SAChdr.user(1).label = char(head3(6,17:24));
i1=2;
for i=7:8,
  for j=[ 1, 9, 17],
    SAChdr.user(i1).label = char(head3(i,j:(j+7)));
    i1=i1+1;
  end
end

% SAChdr.descrip
SAChdr.descrip.iftype = head2(4,1);
SAChdr.descrip.idep = head2(4,2);
SAChdr.descrip.iztype = head2(4,3);
SAChdr.descrip.iinst = head2(4,5);
SAChdr.descrip.istreg = head2(5,1);
SAChdr.descrip.ievreg = head2(5,2);
SAChdr.descrip.ievtyp = head2(5,3);
SAChdr.descrip.iqual = head2(5,4);
SAChdr.descrip.isynth = head2(5,5);

% SAChdr.evsta
SAChdr.evsta.dist = head1(11,1);
SAChdr.evsta.az = head1(11,2);
SAChdr.evsta.baz = head1(11,3);
SAChdr.evsta.gcarc = head1(11,4);

% SAChdr.llnl
SAChdr.llnl.xminimum = head1(12,5);
SAChdr.llnl.xmaximum = head1(13,1);
SAChdr.llnl.yminimum = head1(13,2);
SAChdr.llnl.ymaximum = head1(13,3);
SAChdr.llnl.norid = [];
SAChdr.llnl.nevid = [];
SAChdr.llnl.nwfid = head2(3,2); % waveform id
SAChdr.llnl.nxsize = [];
SAChdr.llnl.nysize = [];
      
% SAChdr.response
SAChdr.response = [head1(5,2:5),head1(6,1:5),head1(7,1)];

% SAChdr
SAChdr.trcLen = head2(2,5);
SAChdr.scale = head1(1,4);
