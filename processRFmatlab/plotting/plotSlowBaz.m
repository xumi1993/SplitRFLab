function [rayp, backaz] = plotSlowBaz( rflist , stnm, isRad , ptype)
% plotSlowBaz : plot slowness and back azimuth of rfn list 
%
% [rayp, backaz] = plotSlowBaz( rflist , stnm, isRad , ptype)
%
% IN:
% rflist = list of rfn structures
% stnm = station name
% isRad = flag to signal slowness is in radians
% ptype = point type , e.g., '.k'
%
% OUT:
% rayp = slowness of rfns in s/km
% backaz = back azimuths in degrees
%

%-- plotSlowBaz.m --- 
%  
%  Filename: plotSlowBaz.m
%  Description: 
%  Author: Iain Bailey
%  Maintainer: 
%  Created: Fri Jul 22 14:43:53 2011 (-0700)
%  Version: 
%  Last-Updated: Tue Aug 23 15:32:22 2011 (-0700)
%            By: Iain Bailey
%      Update #: 9
%  Compatibility: 
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%-- Change Log:
%  
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%-- Code:


RE=6371;
if(nargin < 4), ptype='.k'; end
if(nargin < 3), 
  rayp = getRayP( rflist );
  rayp( rayp>1 ) = rayp( rayp>1 )/RE; 
else
  if( isRad ),
    rayp = getRayP( rflist )/RE; % in s/km
  else
    rayp = getRayP( rflist ); % in s/km
  end
end

backaz = pi*getBackAz( rflist )/180; % in rads

polar( 0.5*pi-backaz, rayp ,ptype);
title(['Back azimuth and slowness (s/km) for station ',stnm] )

% convert back azimuth back into degrees
backaz = 180*backaz/pi;

return
%--------------------------------------------------
function backazs = getBackAz( rflist )

% Extract the back azimuths from the header data

nrf = length(rflist); % number of receiver functions
backazs = zeros( nrf,1 );

for i=1:nrf,
  backazs(i) = rflist(i).evsta.baz;
end

return 

%--------------------------------------------------
function rayps = getRayP( rflist )

% Extract the ray parameters from the header data

nrf = length(rflist); % number of receiver functions
rayps = zeros( nrf,1 );

for i=1:nrf,
  rayps(i) = rflist(i).user(1).data;
end

return 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  This program is free software; you can redistribute it and/or
%  modify it under the terms of the GNU General Public License as
%  published by the Free Software Foundation; either version 3, or
%  (at your option) any later version.
%  
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%  General Public License for more details.
%  
%  You should have received a copy of the GNU General Public License
%  along with this program; see the file COPYING.  If not, write to
%  the Free Software Foundation, Inc., 51 Franklin Street, Fifth
%  Floor, Boston, MA 02110-1301, USA.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plotSlowBaz.m ends here
