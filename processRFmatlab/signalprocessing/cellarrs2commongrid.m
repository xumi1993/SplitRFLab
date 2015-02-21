function [time, seis] =cellarrs2commongrid( times, seiss, commontime )
% 
% [time, seis] =cellarrs2commongrid( times, seiss, commontime )
%
% if we have cell arrays for times and seis, make a common grid 
%
% IN:
% times = cell array of time vectors
% seiss = cell array of corresponding seis amplitude vectors
% commontime = times on which output is desired
%
% OUT:
% time = time of the output grid = same as commontime
% seis = [nt,nseis] 2-d array of seismogram amplitudes

EPS=1e-3; % resolution of the time axis

% get dimensions
nseis = numel( seiss );

% error checking 
if( numel( times )~= nseis ),
  error('cellarrs2commongrid: times and seiss arrays should be the same length');
end

if( nargin < 3 ),
  % work out the time
  
  % get the min and max time
  commontime = times{1};
  tmin = min(commontime);
  tmax = max(commontime);
  
  for i=2:nseis,
    tmin = max( tmin, min(times{i}) );
    tmax = min( tmax, max(times{i}) );
  end
  
  % get unique times within precision and within min/max
  commontime = sort( [times{:}] );
  commontime( diff( [commontime(1)-EPS-1, commontime] ) < EPS ) = [];
  commontime = commontime( commontime >= tmin & commontime <= tmax );

end

nt = numel(commontime);

% make empty
seis = NaN*zeros( nt, nseis );

for i = 1:nseis,
  thist = times{i}(~isnan(seiss{i}));
  thisa = seiss{i}(~isnan(seiss{i}));
  seis(:,i) = interp1( thist, thisa, commontime , 'linear');
end

time = commontime;

return

%-----------------------------------------------------------------