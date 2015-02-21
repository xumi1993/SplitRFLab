function [time, seis, stddev] = phwStack( timelst, seislst, nu, time)
% phwStack - phase weighted stack for a bunch of seismograms
% 
%  [time, seis, stddev] = phwStack( timelst, seislst , time)
%
% IN: 
% timelst = cell array of times for each seis
% seislst = cell array of amplitudes for each seis
% time = optional, time array to compute the stack  on
%
% OUT:
% time = times of stacked seismogram
% seis = stacked seismogram
% stddev = estimate of the standard deviation at each point
%

%-- phwStack.m --- 
%  
%  Filename: phwStack.m
%  Description: 
%  Author: Iain Bailey
%  Maintainer: 
%  Created: Wed Aug 10 10:39:52 2011 (-0700)
%  Version: 
%  Last-Updated: Thu Dec  1 17:18:27 2011 (-0800)
%            By: Iain Bailey
%      Update #: 84
%  Compatibility: 
%  
%--------------------------------------------------
%  
%-- Change Log:
%  
%  
%--------------------------------------------------
%
%-- Code:

ns = numel(seislst); % number of traces

% Check for errors
if( ns ~= numel(timelst ) ),
  error( 'phwStack: Time and seis arrays dont have the same number of elements' )
end

if( ns == 0),
  error('phwStack: No traces in list\n');
  return 
end

if( nargin < 3 ),
  nu = 2; % exponent in stacking
end

if( nargin < 4 ),
  % take time and stack dimensions from the first entry
  time = timelst{1};
% TODO use intersect to get common times
end

nt = numel(time);
stddev = zeros(1,nt); % initial std array

if( ns ==1 ),
  % one trace so return it
  seis = interp1( timelst{1}, seislst{1}, time, 'linear' ,'extrap');
  return
end

all = zeros(ns,nt); % store each seis in a separate row
allphase = zeros(ns,nt); 

% get traces on same axes by interpolation
for is = 1:ns,
  thisseis = interp1( timelst{is}, seislst{is}, time, 'linear' ,'extrap');
  all(is,:) = thisseis;
  s =  hilbert(thisseis);
  allphase(is,:) = s./abs(s);
end

% compute the stack
phasestack = (abs( mean( allphase, 1 ) )).^nu;
seis = mean(all,1).*phasestack;

% standard deviation
stddev = std( all, 0, 1 );%.*(1-phasestack);

return
%--------------------------------------------------
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
%--------------------------------------------------
%-- phwStack.m ends here
