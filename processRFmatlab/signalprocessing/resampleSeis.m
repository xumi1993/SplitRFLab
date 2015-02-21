function [SEIS, DT, TIME] = resampleSeis( SEIS, TIME, DTOUT  )
% Resample seismogram
%
% [SEIS, DT, TIME] = resampleSeis( SEIS, TIME, DTOUT )
% 
% Resample seismogram.  If downsampling use decimate, if upsampling use interpolation
% method.  Values for input and output dt should be fairly similar. 
%
% In: 
% SEIS = Seismogram array (NT x NC), 1 column for each component.  
% TIME = times for all samples in the seis array in s
% DTOUT = desired sample interval in s
%
% Out:
% SEIS = Seismogram array (NT x 3), 1 column for each component.  
% DT = modified sample interval in s
% TIME = new sample times

%-- resampleSeis.m --- 
%  
%  Filename: resampleSeis.m
%  Description: 
%  Author: Iain Bailey
%  Header Created: Fri Nov 18 11:19:53 2011 (-0800)
%  Version: 1
%  Last-Updated: Tue Nov 22 15:10:02 2011 (-0800)
%            By: Iain Bailey
%      Update #: 27
%--------------------------------------------------------
%  
%-- Change Log:
%   Fri Nov 18 2011 : changed downsampling options to use decimate
%  

%-- Notes:
% 
% The matlab resample method has problems getting the desired dt exactly since it wants
% integer ratios
%
% -- Code:

dt = TIME(2) - TIME(1); % existing sample interval
[nt, nseis] = size( SEIS ); % dimensions of array

%if abs( DTOUT - dt) < 1e-8,
if DTOUT == dt,

  % don't bother if they are the same
  DT = dt;
  return;

elseif ( DTOUT > dt ),
  % decrease the sample rate, increase the interval

  r = DTOUT / dt;

  if( abs( r - round(r) ) > 1e-6 ),
    % if not simple factor, upsample first
    r = ceil(r)
    dt_im = DTOUT / r; % intermediate sample rate > initial
    t_im = TIME(1):dt_im:TIME(end);
    SEIS = interp1( TIME, SEIS, t_im, 'cubic' );
    TIME = t_im;
  else
    r = round(r);
  end
  tout =  downsample( TIME, r );  % new time axis
  nt = length( tout ); % new time

  seis2 = zeros( nt, nseis ); % new amplitudes
  for i = 1:nseis,
    seis2(:,i) = decimate( SEIS(:,i), r,'fir');
  end
else
  % increase the sample rate
  tout = TIME(1):DTOUT:TIME(end);

  % use interpolate
  seis2 = interp1( TIME, SEIS, tout, 'cubic' );
end

% get the output quantities
DT = DTOUT;
SEIS = seis2;
TIME = tout;

return

%--------------------------------------------------------
%  
%  This program is free software; you can redistribute it and/or modify it under the terms
%  of the GNU General Public License as published by the Free Software Foundation; either
%  version 3, or (at your option) any later version.
%  
%  This program is distributed in the hope that it will be useful, but WITHOUT ANY
%  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
%  PARTICULAR PURPOSE.  See the GNU General Public License for more details.
%  
%  You should have received a copy of the GNU General Public License along with this
%  program; see the file COPYING.  If not, write to the Free Software Foundation, Inc., 51
%  Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
%  
%--------------------------------------------------------
%-- resampleSeis.m ends here
