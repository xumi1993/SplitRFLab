function [time, rfseis, rfhdr] = processRFwater( nseis, dseis, hdr, opt , isVb )

% Make a receiver function using makeRFwater and process the sac style header file
%
% [time, rfseis, rfhdr] = processRFwater( nseis, dseis, hdr, opt , isVb )
%
% IN:
% nseis = seismogram of numerator
% dseis = seismogram of denominator
% hdr = sac style header containing most info, see sachdr.m
% opt = options...
%    opt.T0 = time rel to t = 0 to start from
%    opt.T1 = time after t=0 to include
%    opt.WLEVEL = water level to use in rfn
%    opt.F0 = gaussian width parameter
% isVb: true = verbose output
%
% OUT:
% time = times for receiver function trace
% rfseis = amplitudes of receiver function
% rfhdr = sac header with modified time and other things...
%      rfhdr.station.kcmpnm = 'RFn'
%      rfhdr.station.cmpaz, cmpinc = -12345
%      rfhdr.user.data(6) = user5 = f0
%      rfhdr.user.data(7) = user6 = rms
%      rfhdr.user.data(8) = user7 = wlevel

%-- processRFwater.m --- 
%  
%  Filename: processRFwater.m
%  Author: Iain William Bailey
%  Created: Mon Jul  4 14:27:10 2011 (-0700)
%  Version: 1
%  Last-Updated: Wed Jul 27 12:58:49 2011 (-0700)
%            By: Iain Bailey
%      Update #: 13
%  Compatibility: 
%  
%-------------------------------------------------------
%  
%-- Change Log:
%     Wed Jul 27 2011 took out the adjusting of cmpaz and cmpinc
%
%  
%-------------------------------------------------------
%  
%-- Code:

if( nargin < 5 ), isVb = false; end % default not verbose

dt = hdr.times.delta; % sample interval
nt = size(nseis, 1); % number of samples

% call the function
[rfseis, rms] = makeRFwater( nseis, dseis, ...
			     -opt.T0, dt, nt, opt.WLEVEL, opt.F0, ...
			     isVb );

% time
time = opt.T0 + dt*(0:1:(length(rfseis)-1));

% Remove the last part
rfseis = rfseis(time<=opt.T1);
time = time(time<=opt.T1); 

% make the header using the original header
rfhdr = hdr;

% adjust the time
rfhdr.times.b = time(1);
rfhdr.times.e = time(end);
rfhdr.trcLen = numel(rfseis);

% change the dependent variable
SAChdr.descrip.idep = 1;

% change the component name
SAChdr.station.kcmpnm = sprintf('%-8s', 'RFn');

% store the f0, wlevel and rms in user data

% user0--user4 reserved for arrival times
rfhdr.user(6).data = opt.F0; % user5 gaussian width
rfhdr.user(6).label = sprintf('%-8s','f0'); % These things won't get written to the sac
					    % file since only two header spaces there

rfhdr.user(7).data = rms; % user6 rms
rfhdr.user(7).label = sprintf('%-8s','Rfn RMS');

rfhdr.user(8).data = opt.WLEVEL; % user7 wlevel
rfhdr.user(8).label = sprintf('%-8s','wlevel');

return
  

%-------------------------------------------------------
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
%-------------------------------------------------------
%-- processRFwater.m ends here
