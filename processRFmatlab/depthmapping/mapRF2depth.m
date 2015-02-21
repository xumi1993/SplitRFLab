function rfout = mapRF2depth( TIME, RF, PP, REGZ, REGVP, REGVS, ...
				   ISPRF )

% 
% For a receiver function and a velocity model convert the time vs
% amplitude to depth vs amplitude.
%
% IN:
% TIME = sample times in seconds
% RF = corresponding amplitudes
% PP = horizontal slowness whichever wave (s/km)
% REGZ = regular depth samples of vel model
% REGVP = p vels (km/s) at regular depth intervals
% REGVS = s vels (km/s) at regular depth intervals
% ISPRF = T: P receiver fn / F: S receiver function
%
% OUT:
% Z = Depth samples (km)
% RFOUT = corresponding amplitudes at those depths
%

%-- mapRF2depth.m --- 
% 
% Filename: mapRF2depth.m
% Description: 
% Author: Iain Bailey
% Maintainer: 
% Created: Mon Jan 31 08:01:37 2011 (-0800)
% Version: 1
% Last-Updated: Mon Jan 31 08:04:37 2011 (-0800)
%           By: Iain Bailey
%     Update #: 4
%
%----------------------------------------------------------------------
% 
%-- Change Log:
% Mon Jan 31 2011 :  Added header and adjusted variable descriptions 
% 
% 
%-- Code:

% get associated vertical slowness
qb = vslow( REGVS(:), PP );
qa = vslow( REGVP(:), PP );

% layer thickness
dz=REGZ(2)-REGZ(1)';

% % get the depths
% z = [0.0; REGZ(:)+0.5*dz];

%vsz = vs.^2 .* qb; % vertical vel ??
%vpz = vp.^2 .* qa; 
%thetap = asind( vp.* PP ); % incidence angles
%thetas = asind( vs.* PP );
  
% get time associated with each depth

if( ISPRF ),
  % P receiver function
  %dt = dz./(vsz) - dz./(vpz) ;
  dt = dz*(qb - qa) ;
  
  t = cumsum(dt);

  % correct for evernecent waves
  t( imag(t)~=0 ) = Inf;
else
  % S receiver function
  %dt = -(dz./(vsz) - dz./(vpz)) ;
  dt = -dz*(qb - qa);

  t = cumsum(dt);

  % correct for evernecent waves
  t( imag(t)~=0 ) = Inf;
end

% get the values of the receiver function at these times
try
  rfout = interp1( TIME, RF, t , 'linear' );
catch ME
  disp( 'problem with interpolation of depth mapped rf' )
  error(ME.message)
end
  
return
%--%--%--%--%--%--%--%--%--%--%--%--%--%--%--%--%--%
%-- mapRF2depth.m ends here
%--%--%--%--%--%--%--%--%--%--%--%--%--%--%--%--%--%
% 
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
%--%--%--%--%--%--%--%--%--%--%--%--%--%--%--%--%--%
