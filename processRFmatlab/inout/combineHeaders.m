function [hdr,t, seis1,seis2,seis3] = combineHeaders(hdr1,seis1,hdr2,seis2,hdr3,seis3,...
						  isPlot,isVb)
% Combine the sac headers from 3 components of the same record into one header
%
% [hdr, seis1,  seis2, seis3] = combineHeaders(hdr1, seis1, hdr2, seis2, hdr3, seis3, isPlot )
%
% From 3 headers with sac files for 3 components, check that the headers are consistent
% and make one single header that applies to all three
%
% In:
%  hdr1, hdr2, hdr3 = sac header files (see sachdr)
%  seis1, seis2, seis3 = corresponding data
%  isPlot = true to plot the seismograms as read in
%
% Out:
%  hdr in same format applying to all three
%  seis1, seis2, seis3 = corresponding data may be adjusted so they are same length

%--- combineHeaders.m --- 
% 
% Filename: combineHeaders.m
% Description: Read 3 components of sac data and make 1 header
% Author: Iain W Bailey
% Maintainer: 
% Created: Mon May  9 15:53:29 2011 (-0700)
% Version: 
% Last-Updated: Thu Nov 17 18:01:20 2011 (-0800)
%           By: Iain Bailey
%     Update #: 53
% 
%--------------------------------------------------------
% 
%--- Change Log:
% Thu Nov 17 2011: added bound for testing sample rates are the same 
%                  added isVb argument
%--------------------------------------------------------
% 
%--- Code:
if( nargin < 7 ), isPlot = false; end
if( nargin < 8 ), isVb = false; end

% make the default header
hdr = hdr3;

% get time info
[t3, dt3, atimes3, labels3] = getTimes( hdr3 );
[t2, dt2, atimes2, labels2] = getTimes( hdr2 );
[t1, dt1, atimes1, labels1] = getTimes( hdr1 );

if( isPlot ), 
  hold on; plot3seis(t1, seis1, t2, seis2, t3, seis3 ); % overlay 
  tmp = input('prompt ');  
end


% check sample intervals are consistent
if( abs( dt3 - dt1 ) > 1e-6 || abs( dt1 - dt2 ) > 1e-6 ), 
  error(['ERROR: Sampling rates not consistent.\n',...
	 'dt_1 = %.12f, dt_2 = %.12f, dt_3 = %.12f'], [dt1,dt2,dt3])
end 

% make start times so origin is at t = 0
t1 = subtractOrigin( t1, hdr1 );
t2 = subtractOrigin( t2, hdr2 );
[ t3, hdr ] = subtractOrigin( t3, hdr );

if( t1(1) ~= t2(1) || t1(1) ~= t3(1) ), 
  if( isVb), 
    fprintf(['Fixing start times.\n',...
	     't0_1 = %f, t0_2 = %f, t0_3 = %f\n'], [t1(1),t2(1),t3(1)]);
  end

  tb = max( [t1(1), t2(1), t3(1)] );
  
  seis1 = seis1( t1 >= tb );
  t1 = t1( t1 >= tb );
  seis2 = seis2( t2 >= tb );
  t2 = t2( t2 >= tb );
  seis3 = seis3( t3 >= tb );
  t3 = t3( t3 >= tb );
  
  hdr.times.b = tb;
  
end 

% check the length of the seismograms
n1 = numel( seis1 );
n2 = numel( seis2 );
n3 = numel( seis3 );
if( n1 ~= n2 || n1 ~= n3 ),
  n = min( [ n1, n2, n3 ] );
  
  seis1 = seis1( 1:n );
  t1 = t1( 1:n );
  seis2 = seis2( 1:n );
  t2 = t2( 1:n );
  seis3 = seis3( 1:n );
  t3 = t3( 1:n );
  
  hdr.trcLen = n;
end

% Remove the things that correspond to one of the components
hdr.station.kcmpnm = sprintf('%-s','-12345');
SAChdr.station.cmpaz = -12345;
SAChdr.station.cmpinc = -12345;

% assign the time
t = t3;

return 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [t, hdr] = subtractOrigin( t , hdr )
% Get origin time relative to p arrival and check
% do this because the p time is more commonly consistent between records

if( isempty(hdr.times.o) || hdr.times.o == -12345 ||  hdr.times.o == 0.0 ), 
 hdr.times.o = 0.0;
 return;
end

to = hdr.times.o;

% remove from the time array
t = t - to;
hdr = shiftSacHdrTimes( hdr, -to ); % update times in the header 

return 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- combineHeaders.m ends here
