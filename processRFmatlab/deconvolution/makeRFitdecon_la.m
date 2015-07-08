function [RFI,RMS,it] = makeRFitdecon_la(UIN,WIN,DT,NT,TSHIFT,F0,ITMAX,MINDERR)
% Iterative t-domain deconv using Ligorria and Ammon's 1999 BSSA method
%
% [RFI,RMS]=makeRFitdecon(UIN,WIN,DT,NT,TSHIFT,F0,ITMAX,MINDERR)
%
% In:
% UIN = numerator (radial for PdS)
% WIN = denominator (vertical component for PdS)
% DT = sample interval (s)
% NT = number of samples
% TSHIFT = Time until beginning of receiver function (s)
% F0 = width of gaussian filter
% ITMAX = max # iterations
% MINDERR = Min change in error required for stopping iterations
%
% Out:
% RFI = receiver function
% RMS = Root mean square error for predicting numerator after each iteration
%

fprintf('Iterative Decon (Ligorria & Ammon):\n')

% Initiate
RMS = zeros(ITMAX,1); % RMS errors
nfft = 2^nextpow2(NT); % number points in fourier transform
P0 = zeros(1,nfft); % predicted spikes

% Resize and rename the numerator and denominator
U0 = zeros( 1, nfft); %add zeros to the end
W0 = U0;
U0(1:NT) = UIN; clear UIN;
W0(1:NT) = WIN; clear WIN;

% get filter in F domain 
gaussF = gaussFilter( DT, nfft, F0 );
% sum(gaussF)
% gaussF = getGfilter( F0, nfft, DT );
% sum(gaussF)/DT

% filter signals
U = gfilter( U0, nfft, gaussF , DT);
W = gfilter( W0, nfft, gaussF , DT);
Wf = fft( W0, nfft ); % W in freq domain ... for convolutions
R = U; %  residual numerator
clear U0 ;%W0;

% Get power in numerator for error scaling
powerU = sum(U.^2);

% Loop through iterations
it = 0;
sumsq_i = 1;
d_error = 100*powerU + MINDERR;
maxlag = 0.5*nfft;
fprintf('\tMax Spike Display is %f', (maxlag)*DT );

%clf;
output = sprintf('File         Spike amplitude   Spike delay   Misfit   Improvement');

while( abs(d_error) > MINDERR  && it < ITMAX )

  it = it+1; % iteration advance

  % ligorria and ammon method
  RW= correl(R, W, nfft);
  RW = RW/sum(W.^2);

  [~,i1]=max( abs( RW(1:maxlag) ) );
  amp = RW(i1)/DT; % scale the max and get correct sign

  % compute predicted deconvolution
  P0(i1) = P0(i1) + amp;  % get spike signal - predicted RF
  P = gfilter(P0, nfft, gaussF, DT); % convolve with filter
  P = gfilter(P, nfft, Wf, DT); % convolve to predict U

  % Uncomment following to view progress
  % clf;
%   subplot(3,1,1); plot(U,'-k'); hold on;
%   subplot(3,1,1); plot(R,'-r'); hold on;
%   subplot(3,1,2); plot(W,'-k'); hold on;
%   subplot(3,1,3); plot(P,'-k'); hold on;% plot(i1,P(i1),'rx');
%   tmp = input('Press a key to continue');

  % compute residual with filtered numerator
  R = U - P;
  sumsq = sum( R.^2 )/powerU;
  RMS(it) = sumsq; % scaled error
  d_error = 100*(sumsq_i - sumsq);  % change in error
  
  sumsq_i = sumsq;  % store rms for computing difference in next

  output = char( output, ...
		    sprintf('%03i %24.9e %11.3f %9.2f %10.4f ',...
			    [it, DT*amp, DT*(i1-1), 100*RMS(it), d_error]));
end

%disp(output)
% pause

% Compute final  receiver function
P = gfilter( P0, nfft, gaussF, DT );

% Phase shift
P = phaseshift(P,nfft,DT,TSHIFT);

% output first nt samples
RFI=P(1:NT);

% output the rms values 
RMS = RMS(1:it);

fprintf('\t# iterations: %i\n', it );
fprintf('\tFinal RMS: %g\n', RMS(it) );
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xnew = gfilter( x, nfft, gauss, dt)
%
%    convolve a function with a unit-area Gaussian filter.
%  
% Liguria & Ammon, use G(omega)=exp(-omega^2/(4.*L^2))  
%  G(f0)=exp(-1/2)=.606
% 
%

% get signal in fourier domain
Xf = fft( x, nfft ); 
%Xf(0) is real, Real(Xf(1)) = Real(Xf(nfft))

% Convolve signal with filter, the dt makes the same units
Xf = Xf.*gauss*dt;

% Back to time domain
xnew = real( ifft( Xf, nfft) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = phaseshift( x, nfft, DT, TSHIFT )
%
%  Add a shift to the data

% into the freq domain
Xf = fft(x, nfft);

% phase shift in radians
shift_i = round(TSHIFT/DT); % removed +1 from here.
p = 2*pi*(1:nfft).*shift_i./(nfft);

% apply shift
Xf = Xf.*(cos(p) - 1i .* sin(p) );

% back into time
x = real( ifft(Xf, nfft) )/cos(2*pi*shift_i/nfft);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = correl( R, W, nfft )
%

%Rf = fft(R,nfft); % convert to freq domain

% Do cross correlation with W in freq
x = real(ifft( fft(R,nfft).*conj(fft(W,nfft)), nfft));
