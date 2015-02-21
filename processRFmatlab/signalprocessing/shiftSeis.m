function [t0, seis] = shiftSeis( seis, t0, dt, tshift , isCirc)
% [t0, seis] = shiftSeis( seis, t0, dt, tshift , isCirc)
%
% shift a seismogram in time
%
% IN:
%  seis is the seismogram amplitudes, can be [nt x nc ] array of
%       aligned components
%  t0 is the time of the first sample point
%  dt is the sample interval
%  tshift is the amount of time to shift
%  isCirc = 1 for circular shift (default), 0 for chopping and adding zeros
%
% OUT:
%  t0 is the modified start time
%  seis is the modified seismogram
%

if( nargin < 5 ), isCirc = 1; end % default is a circular shift

% check dimensions
if( size( seis, 1) == 1 ), 
  seis = seis.'; 
  isSwitched = true;
else
  isSwitched = false;
end

% tshift positive, move everything to the right, negve move to left
nshift=round(tshift/dt);
if nshift == 0, return; end

if( isCirc == 1 ),
  seis = circshift( seis, [nshift, 0] );
  t0 = t0 - nshift*dt;
else
  % preserve the array size, chop and add zeros
  nc = size( seis, 2 ); % number of components/columns
  if nshift < 0,
    nshift = -1*nshift;
    seis = [seis((nshift+1):end,:); zeros(nshift,nc) ]; 
    t0 = t0 + nshift*dt;
  else
    seis = [zeros(nshift,nc); seis(1:(end-nshift-1),:) ];
    t0 = t0 - nshift*dt;
  end
end

if( isSwitched ), seis = seis.'; end 

return 