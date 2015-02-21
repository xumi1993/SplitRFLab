function plotRFgather_rayp( time, seis , rayp, baz, nrf , amp, isReg, atimes)
%
% plotRFgather_rayp( time, seis , rayp, baz, nrf , amp, isReg, atimes)
%
% time is a cell array of time arrays
% seis is a cell array of seis arrays
% baz is an array of back azimuths in radians
% atimes is a cell array of teleseismic arrival times
% nrf is the number of receiver fuctions
% amp is the gain to add to the signals
% isReg = True indicates regularly spaced

%-- plotRFgather_rayp.m --- 
% 
% Filename: plotRFgather_rayp.m
% Description: 
% Author: Iain Bailey
% Maintainer: 
% Created: Fri Jul 22 12:15:18 2011 (-0700)
% Version: 1
% Last-Updated: Tue Aug 23 10:28:14 2011 (-0700)
%           By: Iain Bailey
%     Update #: 24
% Compatibility: Matlab 2011a
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

% get the order of rfns based on the ray parameter
[tmpp, idx] = sort( rayp );

% program will crash if plotting more than ~150, make a random selection
nmax = 150;
if( nrf > nmax ),
  fprintf('nrf is too large. plotting random nrf=%i sample\n',nmax);
  idx2 = randperm(nrf);
  nrf=nmax;
  idx2=idx2(1:nrf);
  idx = idx(idx2);
end


% compute the normalization for amplitudes
nmz = 0.0;
for irf = 1:nrf,
  nmz = max( [nmz, max( abs(seis{idx(irf)}) )]); % normalization factor
end
if(~isReg) nmz = 5000*nmz; end

% plot the receiver functions for this station ordered by slowness
hold on;
for irf = 1:nrf,
  if(isReg)
    xpos = irf - 0.5;
    text(xpos,mint,num2str(rayp(idx(irf)),'%.3f'),'Rotation',90)  
    set(gca,'XTick',[]);
  else
    xpos =  rayp(idx(irf));
    set(gca,'XAxisLocation','top')
    xlabel('Slowness (s/km)')
  end
  
  % plot the coloured trace
  plotseis( xpos + amp*seis{idx(irf)}/nmz, time{idx(irf)} , xpos, 'r' , 'b')


  text(xpos,maxt,num2str(baz(idx(irf)),'%.1f'),'Rotation',270)

  if( nargin > 7 ),
% plot the arrival times
    times = atimes{ idx(irf) };
    times = times( times >= time{idx(irf)}(1) & times <= time{idx(irf)}(end));
    for itime = 1:numel(times),
      plot( xpos, times(itime),'kx' ,'LineWidth',2);
    end
  end

end

ylabel('Time (s)');
axis tight 

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
%-- plotRFgather_rayp.m ends here
