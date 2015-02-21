function plotseis( a, t, a0, c1, c2, var)
% plotseis( a, t, a0, c1, c2, var)
% 
% plot a seismogram vertically, where a=amplitude, t=time, a0=midpoint
% of amplitude (useful if shift is being applied), c1=colour of positive, c2=negative
%
% fills the area under positive amplitudes black

%-- plotseis.m --- 
% 
% Filename: plotseis.m
% Description: 
% Author: Iain Bailey
% Maintainer: 
% Created: Fri Jul 22 12:12:54 2011 (-0700)
% Version: 
% Last-Updated: Fri Jul 22 12:14:43 2011 (-0700)
%           By: Iain Bailey
%     Update #: 5
% Compatibility: 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%-- Change Log:
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%-- Code:

% orient the arrays horizontally
if( size(a,1) > size(a,2) ), a = a'; end
if( size(t,1) > size(t,2) ), t = t'; end

% find the indices before the trace crosses the zero
chg = find( (a(1:end-1)-a0).*(a(2:end)-a0)  < 0 ); 

% interpolate to get the exact times where a=0
t_zero = abs( (a(chg)-a0)./(a(chg+1) - a(chg)) )*(t(2)-t(1)) + t(chg); 

% incorporate the zero times into the array, also add extra start and end point
[t_data, idx] = sort( [t(1), t, t_zero, t(end)] );

% incorporate a=0 into array, make a=0 at t(1) and t(end) too
a_data = [a0, a, a0.*ones(1,length(t_zero)+1) ];
a_data = a_data(idx);

% plot filled regions for the positive amplitudes
fill( a_data(a_data>=a0), t_data(a_data>=a0), c1 );hold on;
fill( a_data(a_data<=a0), t_data(a_data<=a0), c2 );hold on;

% paint over the central line with white
plot( [a0, a0], [t(1),t(end)], 'w-' );

% overlay the full trace to get the negative parts and obscure the white line
plot( a, t , '-k' , 'LineWidth', 1.5); hold on;

% plot the variance
if( nargin > 5 ),
  if( size(var,1) > size(var,2) ), var = var'; end
  plot( a+sqrt(var), t , '-k' ); hold on;
  plot( a-sqrt(var), t , '-k' ); hold on; 
end
set(gca,'YDir','reverse');

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- plotseis.m ends here
