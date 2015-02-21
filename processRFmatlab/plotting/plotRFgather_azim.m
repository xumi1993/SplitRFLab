function plotRFgather_azim( time, seis , rayp, baz, atimes, nrf , amp, isReg)

% plot rfn gather ordered by back-azimuth
%
% plotRFgather_azim( time, seis , rayp, baz, atimes, nrf , amp, isReg)
%
% time is a cell array of time arrays
% seis is a cell array of seis arrays
% baz is an array of back azimuths in radians
% atimes is a cell array of teleseismic arrival times
% nrf is the number of receiver fuctions
% amp is the gain to add to the signals
% isReg = True indicates regularly spaced

%-- plotRFgather_azim.m --- 
%  
%  Filename: plotRFgather_azim.m
%  Description: 
%  Author: Iain Bailey
%  Maintainer: 
%  Created: Fri Jul 22 12:09:17 2011 (-0700)
%  Version: 1
%  Last-Updated: Fri Jul 22 12:12:24 2011 (-0700)
%            By: Iain Bailey
%      Update #: 7
%  Compatibility: Matlab 2011a
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%-- Change Log:
%  
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%-- Code:

% get the plot limits
mint = min( [time{:}] );
maxt = max( [time{:}] );

% get the order of rfns based on back azimuth
[tmpb, idx] = sort( baz );

% compute the normalization for amplitudes
nmz = 0.0;
for irf = 1:nrf,
  nmz = max( [nmz, max( abs(seis{idx(irf)}) )]); % normalization factor
end

% plot the receiver functions for this station ordered by back azimuth
hold on;
for irf = 1:nrf,
  if(isReg)
    xpos = irf - 0.5;
    text(xpos,mint,num2str(baz(idx(irf)),'%.1f'),'Rotation',90)
    set(gca,'XTick',[]);
  else
    xpos =  baz(idx(irf));
    set(gca,'XAxisLocation','top')
    xlabel('Back Azimuth (^o)')
  end
  
  % plot the coloured trace
  plotseis( xpos + amp*seis{idx(irf)}/nmz, time{idx(irf)} , xpos, 'r' , 'b')


  text(xpos,maxt,num2str(rayp(idx(irf)),'%.3f'),'Rotation',270)  

  % plot the arrival times
  times = atimes{ idx(irf) };
  times = times( times >= time{idx(irf)}(1) & times <= time{idx(irf)}(end));
  for itime = 1:numel(times),
    plot( xpos, times(itime),'kx' ,'LineWidth',2);
  end
  

end

axis tight 

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
%-- plotRFgather_azim.m ends here
