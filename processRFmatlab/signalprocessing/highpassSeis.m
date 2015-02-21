function SEIS=highpassSeis(SEIS, DT, FHP,NORD)
% high pass a seismogram
%
% SEIS = highpassSeis(SEIS, DT, FHP, FLP)
% SEIS = highpassSeis(SEIS, DT, FHP, FLP ,NORD)
%
% High pass all components of the seismogram using a (default) 2nd order
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

%   highpassSeis.m --- 
%  
%  Filename: highpassSeis.m
%  Description: band pass 3 component seismograms
%  Author: Iain W. Bailey 
%  Maintainer: I. W. Bailey
%  Created: Wed Nov 23 10:00:26 2011 (-0800)
%  Version: 1
%  Last-Updated: Wed Nov 23 11:06:43 2011 (-0800)
%            By: Iain Bailey
%      Update #: 31
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
if( nt == 1 ), 
  nt = nc; nc = 1; SEIS = SEIS.';
end

% Nyquist frequency
fny=0.5/DT;

% Passband array for butterworth filter
wn = FHP./fny;

% make the butterworth filter
[z, p, k] = butter( norder, wn, 'high' );
[sos,g] = zp2sos(z,p,k);% Convert to SOS form

%Apply the band pass filter to each component
SEIS = sosfilt( sos, SEIS, 1);

return;

%----------------------------------------------------------------------
%   highpassSeis.m ends here
