function [RFt, rms, nwl] = makeRFwater_ammon( UIN, WIN, TDEL, DT, NT, ...
					      WLEVEL, F0, VB)
% Water level deconvolution
%
% [RFt, rms, nwl] = makeRFwater_ammon( UIN, WIN, TDEL, DT, NT, WLEVEL, F0)
%
% Use Ammon's code (rewritten in matlab) to do water level
% deconvolution using the method of langston (1979)
%
% IN: 
% UIN = numeratory amplitudes 
% WIN = denominator amplitudes
% TDEL = time delay to add (s)
% DT = sample interval (s)
% NT = number samples
% WLEVEL = lowest value accepted (percentage of max)
% F0 = gaussian filter width parameter (Hz)
% VB = verbose output
%
% OUT:
% RFt = receiver function
% rms = percentage of numerator power not fit by conv(RFt,WIN)
% nlw = number of samples set to water level

%--- makeRFwater_ammon.m --- 
% 
% Filename: makeRFwater_ammon.m
% Description: 
% Author: T Owens (1982), G Randall, C Ammon, IW Bailey (2010)
% Maintainer: IW Bailey
% Created: Wed Dec  1 15:14:44 2010 (-0800)
% Version: 1
% Last-Updated: Mon Jul  4 18:28:01 2011 (-0700)
%           By: Iain William Bailey
%     Update #: 263
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%--- Commentary: 
% 
%  From fortran code:
%    fortran 77 program to perform a source equalization deconvolution
%     on a three component seismogram - using the method of langston (1979)
%
%    *** written by t.j. owens - july 1982
%    *** modified by G Randall for gaussian normalization
%    *** modified by C Ammon for water-level normalization 880711
%
%	This program has had too many authors and contains
%       some inevitable, unnecessary complications in
%	   the code.  Still, it works, and the code is fairly
%	   straight forward to follow.  Moral -> 3 programmers
%	   will program less efficiently than any of the indivduals.
%							CJA 880722
%
%     910804  added the output of the averaging function - Ammon
%
%     960623  added longer filenames (subs.a) and different begin time
% 
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
nft = 2^nextpow2(NT);  % nearest greater power of 2
nfpts = nft/2 + 1;     % number of freq samples
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
% Uf = fft( UIN(1:nfpts), nft );
% Wf = fft( WIN(1:nfpts), nft );
Uf = fft( UIN, nft );
Wf = fft( WIN, nft );

% denominator
Df = Wf.* conj(Wf);
dmax = max( real( Df ) );

% add water level correction
phi1 = WLEVEL*dmax; % water level
nwl = length( find(Df<phi1) ); % number corrected
Df( real(Df)<phi1 ) = phi1;

if( VB ),
  fprintf('Dmax: %.3e, W. level: %.3e, Number corrected: %i/%i\n',...
	  [dmax, phi1, nwl,numel(Df)]);
end

% compute gaussian filter
gaussF = gaussFilter( DT, nft, F0 );
% zeros( 1, nft );
% gaussF(1:nfpts) = exp(-w.*w./(4.*F0*F0))/DT;
% gaussF(nfpts+1:end) = fliplr(gaussF(2:nfpts-1)); % negative frequencies
% gaussF(nfpts) = 0.0;  % zero at nyquist

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
  fprintf('Finished. Misfit = %.2f per cent \n',rms)
end

% if we want a unit amplitude gaussian filter apply the following
if isUnitAmp,
  gnorm = sum(gaussF)*delf*DT;
  RFt = real(RFt)/gnorm;
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
%--- makeRFwater_ammon.m ends here
