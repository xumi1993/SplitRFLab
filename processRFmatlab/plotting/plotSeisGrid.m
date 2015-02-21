function clims = plotSeisGrid( gridx, gridy, x, y, seis, clims )
% plotSeisGrid: plot seismograms on a grid
%
% plotSeisGrid( gridx, gridy, x, y, seis )
%
% IN:
% gridx,gridy = grid positions to plot
% x = the grid positions corresponding to the columns of the seis array
% y = the grid positions corresponding to the rows of the seis array
% seis = the seismogram amplitudes at x and y positions
%


%-- plotSeisGrid.m --- 
% 
% Filename: plotSeisGrid.m
% Description: 
% Author: Iain Bailey
% Maintainer: 
% Created: Tue Aug 23 14:52:10 2011 (-0700)
% Version: 
% Last-Updated: Fri Sep 16 18:28:56 2011 (-0700)
%           By: Iain Bailey
%     Update #: 22
% URL: 
% Keywords: 
% Compatibility: 
% 
 
%-- Change Log:
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%-- Code:

% find dimensions of grid to plot
nx = numel(gridx);
ny = numel(gridy);
seis2 = zeros( ny, nx );

% get parts of grid where we have data
[~, igridx, ix] = intersect( round(gridx*10000), round(x*10000) );
[~, igridy, iy] = intersect( round(gridy*10000), round(y*10000) );

if( numel(ix) == 0 )
  error('no overlap in x direction')
elseif( numel(iy) == 0 )
  error('no overlap in y direction')
end

% allocate to plotting array
seis2( igridy, igridx ) = seis(iy,ix);

% get colour scale limits
if( nargin < 6 )
  maxA = max(max(abs(seis2)));
  clims = [-maxA, maxA ];
end

% get the colour map
%mycmap = repmat( sin( pi*(1:64-1) /63 )', 1, 3 );
mycmap = repmat( [linspace(0,1,32), linspace(1,0,32)]', 1, 3 );
mycmap(1:32,3) = ones(32,1);
mycmap(33:64,1) = ones(32,1);
colormap(  mycmap );

% plot the result
imagesc( gridx, gridy, seis2, clims )
axis tight;

% move x axis to the top
set(gca,'XAxisLocation','top')

% plot a colour bar
% colorbar
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
%-- plotSeisGrid.m ends here
