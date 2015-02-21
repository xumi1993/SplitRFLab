function [RFt, rms] = makeRFdamp( UIN, WIN, TDEL, DT, NT, ...
				       DAMP, F0, VB)
% Deconvolution using a constant damping factor
%
% [RFt, rms, nwl] = makeRFdamp( UIN, WIN, TDEL, DT, NT, WLEVEL, F0)
%
% Do deconvolution using the method of ??langston (1979)
%
% IN: 
% UIN = numeratory amplitudes 
% WIN = denominator amplitudes
% TDEL = time delay to add (s)
% DT = sample interval (s)
% NT = number samples
% DAMP = factor to add on to denominator (percentage of max)
% F0 = gaussian filter width parameter (Hz)
% VB = verbose output
%
% OUT:
% RFt = receiver function
% rms = percentage of numerator power not fit by conv(RFt,WIN)

%--- makeRFdamp.m --- 
% 
% Filename: makeRFdamp.m
% Description: 
% Maintainer: IW Bailey
% Created: Tue Mar 29 11:49:51 2011 (-0700)
% Version: 1
% Last-Updated: Fri Nov 25 22:02:56 2011 (-0800)
%           By: Iain Bailey
%     Update #: 38
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%--- Change Log:
% 
% 
%--- Code:
if( nargin < 8 ), VB = true; end
isUnitAmp = 0;

% get dimensions right
if( size(UIN,1) > size(UIN,2) ), UIN = UIN.'; end
if( size(WIN,1) > size(WIN,2) ), WIN = WIN.'; end

% ft params
nft = 2^nextpow2(2*NT);  % nearest greater power of 2, use double time to avoid overlap
nfpts = nft/2 + 1;     % number of freq samples in this range
fny = 1./(2.*DT);      % nyquist
delf = fny/(0.5*nft);

if( VB ),
  fprintf('nt: %i, nfpts: %i, nft: %i, fny: %.2f, df: %.3f\n',...
	  [NT, nfpts, nft, fny, delf]);
end

% frequencies
freq = delf*(0:1:(nfpts-1));
w = 2*pi*freq;

% containers
RFf = zeros(1,nft); % Rfn in freq domain
UPf = zeros(1,nft); % predicted numer in freq domain

% Convert seismograms to freq domain
Uf = fft( UIN(1:NT), nft );
Wf = fft( WIN(1:NT), nft );

% denominator
Df = Wf.* conj(Wf);

% add damp  correction
Df = Df + DAMP*max( real( Df ) );

% compute gaussian filter
gaussF = gaussFilter( DT, nft, F0 );

% numerator
Nf = gaussF .* Uf .* conj(Wf);

% compute RF
RFf = Nf ./ Df;

% compute predicted numerator
UPf = RFf.*Wf;

% add phase shift to RF
w = [w, -fliplr(w(2:end-1))];
RFf = RFf .* exp(-1i*w*TDEL);

% back to time domain
RFt = ifft( RFf , nft );
RFt = real(RFt(1:NT));

% compute the fit
Uf = gaussF.*Uf; % compare to filtered numerator
Ut=real( ifft(Uf, nft ) );
UPt=real( ifft(UPf, nft ) );

powerU = sum((Ut(1:NT)).^2);
rms = sum( (UPt(1:NT) - Ut(1:NT) ).^2 )/powerU;

if( VB ),
  fprintf('Finished. Misfit = %.2f per cent \n',100*rms)
end

% if we want a unit amplitude gaussian filter apply the following
if isUnitAmp,
  RFt = real(RFt)/sum(gaussF)*delf*DT;
end

return 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%--- makeRFdamp.m ends here
