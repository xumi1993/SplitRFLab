function [besth, bestk, allstack] = getBestHK( rflist , vp, w, h, k )
% [besth, bestk, allstack] = getBestHK( rflist , vp, w, h, k )
% Use stacking to get estimate of best crustal thickness and Vs 

if( nargin < 2 ), vp = 6.30; end; % default Vp
if( nargin < 3 ), w = [ 1, 1, 1 ]; end % default weighting of multiples
if( nargin < 4 ), h = 20:0.5:60; end % default crustal thicknesses to try
if( nargin < 5 ), k = 1.5:0.01:2.0; end % default Vp/Vs to try
  
% convert rflist to correct input file
nrf = numel(rflist);
[t0, dt, rfdata, p ] = getSeisData(rflist, nrf);

% do the hk stacking
[stack, stackvar ] = hkstack_iwb( rfdata, t0, dt, p, h, k, vp);

% combine the stacks 
allstack = w(1)*stack(:,:,1) + w(2)*stack(:,:,2) + w(3)*stack(:,:,3);
[maxA, i] = max(max(allstack));
[i,j] = find( allstack == maxA ,1);
besth = h(j);
bestk = k(i);

return

% --------------------------------------------------
function [t0, dt, seiss, rayp] = getSeisData( rflist, nrf)

% Extract the time and seismogram data so that the seismograms are aligned

% get the initial time
t0 = min( [ rflist.t ] );
tend = max( [ rflist.t ] );

rayp = zeros(1,nrf);

% check the sample interval, get the slowness
alldt = zeros(nrf, 1);
for i =1:nrf, 
  alldt(i) = rflist(i).times.delta;
  rayp(i) = rflist(i).user(1).data;
end
if( max( diff( alldt ) ) ~= 0 ),
  error(['sample intervals are not the same among receiver functions. you need to', ...
	 ' resample']);
else
  dt = alldt(1);
end
  
% common time array
tmpt = t0:dt:tend;
nt = numel(tmpt);

% create seis array, seismograms in columns
seiss = zeros( nt, nrf );

for i=1:nrf,
  [tmpVal, idxA, idxB] = intersect( rflist(i).t, tmpt );
  seiss( idxB, i ) = rflist(i).seis(idxA);
end

return 

