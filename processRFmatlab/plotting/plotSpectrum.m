function plotSpectrum( seis, dt , ltype)
% plot the frequency spectrum of a seismogram
%
% plotSpectrum( seis, dt )
%
% Take the fourier transform of a seismogram, plot the spectrum to
% the current figure
%
% IN:
% seis = the seismogram to plot
% dt = the sample interval in seconds

%--- plotSpectrum.m --- 
%  
%  Filename: plotSpectrum.m
%  Description: 
%  Author: Iain William Bailey
%  Maintainer: 
%  Created: Sun Jun 26 10:45:25 2011 (-0700)
%  Version: 
%  Last-Updated: Sun Jun 26 11:35:46 2011 (-0700)
%            By: Iain William Bailey
%      Update #: 71
%  Compatibility: 
%  
%--- Change Log:
%  
%  
%--- Code:

if( nargin < 3 ),
  ltype='-k';
end

% get the fourier transform properties
nt = numel(seis); % number samples
fny = 0.5/dt; % nyquist freq
nfft = 2^nextpow2( nt ); % number of points in the fft

% compute the frequency range for positive frequencies
f = fny*linspace(0,1,0.5*nfft+1);

% get the amplitude of the fourier transform
% TODO this normalisation may not be correct
Yn = 2*abs( fft(seis,nfft) ) /(dt*nt);

% get the positive half and square to get the power
Yn = Yn(1:(nfft/2)+1).^2;

loglog(f,Yn,ltype,'LineWidth',1.5)
xlabel('Frequency (Hz)')
ylabel('Power')
axis tight;

%----------------------------------------------------------------------
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
%--- plotSpectrum.m ends here
