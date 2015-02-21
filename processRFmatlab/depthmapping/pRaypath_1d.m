function [epos, npos, zpos ] = pRaypath_1d( p, backaz, dz, zmax, z, vp )

 
%- Code:
EPS = 1e-6;
nseis = numel( p );
if( nseis > 1 ),
  if( size(p,1) > size(p,2) ) p = p';
  end
end

% get the depths
zpos = (0.0:dz:zmax)';
nz = numel(zpos);

% deal with discontinuities in the vel model
idisc = find( z(1:end-1) == z(2:end) );
z(idisc) = z(idisc) - EPS;

% interpolate the vel model between each layer
vp = interp1( z, vp, zpos(1:end-1)+0.5*dz, 'linear','extrap');  

% repeat matrices
p = repmat( p, nz-1, 1 );
backaz = repmat( backaz, nz-1, 1 );
vp = repmat( vp, 1, nseis );

% get associated vertical slowness
qa = sqrt(1./vp.^2 - p.^2);

% get horizontal position
dh = p.*dz./qa;
% dt = qa*.*dz + p.*dh

hpos = cumsum( dh, 1 );
epos = [zeros(1,nseis) ; hpos.*sind(backaz)];
npos = [zeros(1,nseis) ; hpos.*cosd(backaz)];

return


return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


%%% sRayPath.m ends here
