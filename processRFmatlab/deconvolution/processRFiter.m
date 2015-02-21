function [time, rfseis, rfhdr] = processRFiter( nseis, dseis, hdr, opt , isVb );

% Make a receiver function using makeRFiter and process the sac style header file
%
% [time, rfseis, rfhdr] = processRFiter( nseis, dseis, hdr, opt , isVb )
%
% IN:
% nseis = seismogram of numerator
% dseis = seismogram of denominator
% hdr = sac style header containing most info, see sachdr.m
% opt = options...
%    opt.T0 = time before t = 0 to include
%    opt.T1 = time after t=0 to include
%    opt.F0 = gaussian width parameter
%    opt.itermax = max number of iterations
%    opt.minderr = exit iterations if change in error is less 
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
%      rfhdr.user.data(8) = user7 = number of iterations

%-- processRFiter.m --- 
%  
%  Filename: processRFiter.m
%  Author: Iain William Bailey
%  Created: Mon Jul  4 14:27:10 2011 (-0700)
%  Version: 1
%  Last-Updated: Fri Sep 23 12:16:11 2011 (-0700)
%            By: Iain Bailey
%      Update #: 21
%  Compatibility: 
%  
%-------------------------------------------------------
%  
%-- Change Log:
%   Wed Jul 27 2011 took out the adjusting of cmpaz and cmpinc
%  
%-------------------------------------------------------
% TODO 

if( nargin < 5 ), isVb = false; end % default not verbose

dt = hdr.times.delta; % sample interval
nt = size(nseis, 1); % number of samples

% call the function
tshift=0.0;

[rfseis, rms] = makeRFitdecon( nseis, dseis, ...
                               dt, opt.T0, opt.T1, tshift, opt.F0,...
			       opt.ITERMAX, opt.MINDERR , isVb );

if(numel(rms)==0),
  error('RMS array is empty')
end

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

rfhdr.user(7).data = rms(end); % user6 rms
rfhdr.user(7).label = sprintf('%-8s','Rfn RMS');

rfhdr.user(8).data = length(rms); % user7 number of iterations
rfhdr.user(8).label = sprintf('%-8s','niter');

return
  
