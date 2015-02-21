function [depths, epos, npos, seisout] = mapSpSeis2depth_1d( time, seis, p, backaz, dz, z, vp, vs )

EPS = 1e-6;

nseis = numel( p );

% get the depths
zout = (0.0:dz:2800);

% deal with discontinuities in the vel model
idisc = find( z(1:end-1) == z(2:end) );
z(idisc) = z(idisc) - EPS;

% interpolate the vel model in middle of each interval
vp = interp1( z, vp, zout(1:end-1)+0.5*dz, 'linear','extrap');
vs = interp1( z, vs, zout(1:end-1)+0.5*dz, 'linear','extrap');  

for iseis = 1:nseis,

  % get associated vertical slowness
  qa = sqrt(1./vp.^2 - p(iseis).^2);
  qb = sqrt(1./vs.^2 - p(iseis).^2);

  % get time difference
  dt = dz*(qa - qb); % time difference at each depth interval
  tout = [ 0, cumsum(dt) ];

  % get rid of times and depths before start of the seismogram
  idx = find( tout >= min(time{iseis} ) );
  tout = tout( idx );
  depths{iseis} = zout( idx );

  % get depths
  depths{iseis} = zout( idx );
  
  tout( imag(tout)~=0 ) = Inf;   % correct for evernecent waves

  % get amplitudes
  seisout{iseis} = interp1( time{iseis}, seis{iseis}, tout , 'linear' );

  seisout{iseis}(tout == Inf) = NaN;   % correct for everne
  
  % get horizontal positions
  dh = dz*p(iseis)./qa(idx);
  hpos{iseis} = [ 0, cumsum(dh(1:end-1)) ];
  epos{iseis} = hpos{iseis}.*sind(backaz(iseis));
  npos{iseis} = hpos{iseis}.*cosd(backaz(iseis));

end
  
return

% ---------------------------------------------------------------------- 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; see the file COPYING.  If not, write to
% the Free Software Foundation, Inc., 51 Franklin Street, Fifth
% Floor, Boston, MA 02110-1301, USA.
% 
% ---------------------------------------------------------------------- 

