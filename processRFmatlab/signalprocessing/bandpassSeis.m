function SEIS=bandpassSeis(SEIS, DT, FHP, FLP ,NORD)
% Bandpass a seismogram
%
% SEIS = bandpassSeis(SEIS, DT, FHP, FLP)
% SEIS = bandpassSeis(SEIS, DT, FHP, FLP ,NORD)
%
% Band pass all components of the seismogram using a 2nd order
% butterworth filter with 2 passes.  The cutoff frequency must be 0.0
% < Wn <= 1.0, with 1.0 corresponding to half the sample rate, or will
% return an error.
%
% IN: 
% SEIS = Seismogram array (NT x NC), 1 column for each component.  
% DT = sample interval in s
% FHP = high pass freq in Hz 
% FLP = low pass freq in Hz (FHP<FLP)
% NORD = order of filter
%
% OUT:
% SEIS = seismogram after band pass
%
%

%   bandpassSeis.m --- 
%  
%  Filename: bandpassSeis.m
%  Description: band pass 3 component seismograms
%  Author: Iain W. Bailey and A Levander
%  Maintainer: I. W. Bailey
%  Created: Thu Oct 21 10:11:37 2010 (-0700)
%  Version: 1
%  Last-Updated: Wed Nov 23 11:07:10 2011 (-0800)
%            By: Iain Bailey
%      Update #: 35
%  
%----------------------------------------------------------------------
%  
%   Change Log:
%  
%  
%----------------------------------------------------------------------
%  
%   Code:

if( nargin < 5)
  norder=2;
else
  norder=NORD;
end

% Get the number of components read in
[nt, nc] = size(SEIS);% number of samples and components

% Nyquist frequency
fny=0.5/DT;

% Passband array for butterworth filter
wn = [ FHP, FLP ]./fny;

% Error check
if( wn(2) > 1.0 ),
  error( 'Low pass is too high: Need to downsample data.' );
end

% make the butterworth filter
%[b, a] = butter( norder, wn , 'bandpass');
[z, p, k] = butter( norder, wn, 'bandpass' );
[sos,g] = zp2sos(z,p,k);% Convert to SOS form

% zero phase filter
for i=1:nc,
  % Do 2 passes with the filter
  %SEIS(:,i) = filtfilt( b, a, SEIS(:,i));
  SEIS(:,i) = filtfilt( sos, g, SEIS(:,i));
end

return;

%----------------------------------------------------------------------
%   bandpassSeis.m ends here
