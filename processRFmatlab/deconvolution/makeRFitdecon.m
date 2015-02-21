function [RFI,RMS] = makeRFitdecon(UIN,WIN,DT,...
				   MINLAG,MAXLAG,TSHIFT,F0,...
				   ITMAX,MINDERR,ISVB)
% Iterative time domain deconvolution 
%
% [RFI,RMS]=makeRFitdecon(UIN,WIN,DT,MINLAG,MAXLAG,F0,ITMAX,MINDERR,ISVB)
%
% Iterative time-domain deconvolution using Ligorria and Ammon's 1999
% BSSA method, modified.  The main difference is that we use matlab
% functions to avoid wraparound during cross correlation and
% convolution operations.  For the cross correlation, we also truncate the 
% denominator so that all x-correlations involve the same number of data points.
% However, the predicted receiver function utilizes the entire denominator to 
% compare to the entire length of the numerator 
% 
% The algorithm may take longer than the ligorria/ammon method because done in the 
% time domain. Fit values may also differ.
%
% In:
% UIN = numerator (radial for PdS)
% WIN = denominator (vertical component for PdS)
% DT = sample interval (s)
% MINLAG = Min rf lag time  (usually 0 for p->s, -ve for s->p) 
% MAXLAG = Max rf lag time  (usually +ve for p->s, 0 for s->p) 
% F0 = width of gaussian filter
% ITMAX = max # iterations
% MINDERR = Min change in error required for stopping iterations
% TSHIFT = Time until beginning of receiver function (s)
% ISVB = flag for verbose output
%
% Out:
% RFI = receiver function
% RMS = Root mean square error for predicting numerator after each iteration
%

%--- makeRFitdecon.m --- 
% 
% Filename: makeRFitdecon.m
% Description: 
% Author: I. W. Bailey, J. Ligorria, C. Ammon, A Levander
% Maintainer: I. W. Bailey
% Created: Thu Oct 21 10:18:41 2010 (-0700)
% Version: 
% Last-Updated: Tue Aug  9 08:55:12 2011 (-0700)
%           By: Iain Bailey
%     Update #: 335
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%--- Change Log:
%
% Wed Jun 15 2011 - Realised why I shouldn't have messed with this.  The predicted
% numerator requires a convolution between the entire denominator and the receiver
% function so that the output is the correct length.  Now modified so that the correlation
% always uses the same length denominator, but the subsequent convolution uses the
% original denominator.
%
% Tue Jun 14 2011 - Changed again.  The cross corellations must consider the same signal
% length for different lags so we make the denominator zero where the receiver function
% lag is incorporated - In the process, removed the nt since it is already defined by
% minlag, maxlag and dt arguments.
%
% Thu Nov 18 2010 - Added more comments to program description - Removed the specifying of
% numerator signal.. This was a misstep since I still want a single spike at t=0 to
% predict the full numerator.  - Cleaned up output by adding zeros.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%- Code:

% Initiate store for success of fits
RMS = zeros(ITMAX,1); % RMS errors

ntin = numel(UIN); % number of elements in numerator
if( ntin == 0 ),
  error('Zero length numerator')
elseif( numel( WIN ) < ntin ),
  error('makeRFitdecon: numerator and denominator dimensions dont match');
end

% check orientation
if( size(UIN,1)>size(UIN,2) ), UIN = UIN.'; end
if( size(WIN,1)>size(WIN,2) ), WIN = WIN.'; end

% check the lags make sense
endnlag = max( round( MAXLAG/DT ), 0 );
begnlag = max( round( -MINLAG/DT), 0 );
while( begnlag + endnlag > ntin ),
  fprintf('WARNING: %f,%f lags not possible when %i points in denom\n',...
	  [MINLAG,MAXLAG,ntin])
  % reduce by half
  if( begnlag > 0 ), 
    MINLAG = 0.5*MINLAG
    begnlag = max( round( -MINLAG/DT), 0 );
  end
  if( endnlag > 0 ),
    MAXLAG = 0.5*MAXLAG
    endnlag = max( round( MAXLAG/DT ), 0 );
  end
end

ntdenom = ntin - begnlag - endnlag; % number points used in x correlations

% check again 
if( begnlag+endnlag > 0.5*ntin ),
  fprintf(['WARNING (makeRFitdecon):',...
	   ' It is better to use RF length < 0.5*trace length.',...
	   ' Otherwise you are predicting some parts of the numerator' ...
	   ' using a small number of points in the denominator.\n'])
  fprintf('Currently only using %i points in the denominator\n',ntdenom)
end

% Set up the denominator
W = zeros(1,ntin); % zeros for lagged points
W(begnlag+1:end-endnlag) = WIN(begnlag+1:end-endnlag); % denominator

% Set up gaussian filter and numerator
sigma = 1/( sqrt(2)*F0 );  
gaussT = DT*normpdf( DT*(0:ntin-1), DT*round(0.5*ntin-0.5), sigma );

U = conv( UIN(1:ntin), gaussT, 'same');  % filtered numerator
W = conv( W, gaussT, 'same'); % filtered denominator
R = U; % initial residual numerator
invpowerU = 1/sum(U.^2); % power in filtered numerator for error scaling
invpowerW = 1/sum(conv(WIN(1:ntin),gaussT,'same').^2); % for scaling the auto-correlation

% print info to screen
if(ISVB),
  fprintf('Iterative Deconvolution\n')
  fprintf('\tNum signal has length of %.2f\n',...
	  [ntin*DT])
  fprintf('\tUsed Denom signal has length of %.2f\n',...
	  [ntdenom*DT])
  fprintf('\tCalculating RF for times in range %.2f--%.2f s\n',...
	  [-begnlag*DT,endnlag*DT])
end

lag1=-begnlag; % lag to use in auto correlation
lag2=endnlag;
maxlag = max(begnlag,endnlag); % max abs lag used in rfn
P0 = zeros( 1, 2*maxlag + 1 ); % predicted spikes for RF

% Loop through iterations
it = 0; % iteration counter
sumsq_i = 1.0; % sum squared error in prev. iteration
d_error = 100*sum(U.^2) + MINDERR; % change in error from one iteration to next

% Title for prog report
output = sprintf('File         Spike amplitude   Spike delay   Misfit   Improvement');

while( abs(d_error) > MINDERR  && it < ITMAX )

  it = it+1; % iteration advance

  % correlate residual numerator with filtered chopped denominator , no scaling
  [RW, lags]= xcorr(R, W, maxlag, 'none' );

  RW = RW*invpowerW;  % scale by the power of filtered chopped denominator

  % get lag and size of strongest signal within accepted lag range
  oklag = find( (lags >= lag1) & (lags <= lag2) );
  [maxRW idx]= max( abs( RW(oklag) ) );
  idx = oklag(idx);
  amp = RW(idx)/DT;
  
  % Create a spike at correct time with correct amplitude
  P0(idx) = P0(idx) + amp; 

  % Convert to predicted RF by filtering
  RFP = conv( P0, gaussT, 'same'); 
  
  % Predict numerator by convolving with unfiltered full denominator
  UP = conv( WIN(1:ntin), RFP, 'same')*DT;  % predicted U

%   % Uncomment following to view progress
%     if( ISVB ),
%       disp(['It: ',num2str(it),', Lag:',num2str(lags(idx)),...
%              ', ',num2str(lags(idx)*DT)])
%       plot_progress(ntin,R,W,lags,RW,RFP,U,UP )
%     end
  
  % Get the new residual
  R = U - UP; 

  % Compute the scaled error in the fit
  sumsq = sum( R.^2 )*invpowerU;
  RMS(it) = sumsq; % scaled error
  d_error = 100*(sumsq_i - sumsq);  % change in error
  
  sumsq_i = sumsq;  % store rms for computing difference in next

  output = strvcat( output, ...
		    sprintf('%03i %24.9e %11.3f %9.2f %10.4f ',...
			    [it, DT*amp, DT*(lags(idx)), 100*RMS(it), d_error]));
end

if( ISVB), disp(output)
end

% Compute final  receiver function
RFP = conv( P0, gaussT, 'same'); % gaussian filter

idx1=maxlag+lag1+1; % maxlag +1 is the index of zero time delay
idx2=maxlag+lag2+1;

% include time shift
shifti = round(TSHIFT/DT);
if( shifti == 0 ),
  % no time shift
  RFI = RFP(idx1:idx2);
elseif( shifti > 0 ),
  % positive time shift: use part of signal or add zeros
  idx1 = idx1 -shifti;
  if( idx1 <= 0 ),
    RFI= [zeros(1,1-shifti), RFP(1:idx2)];
  else
    RFI= RFP(idx1:idx2);
  end
else
   % negative time shift: truncate 
  idx1 = idx1 - shifti;
  idx2 = min(numel(RFP),idx2-shifti);
  RFI = RFP(idx1:idx2)
end


% keep only the RMS values for the iterations performed
RMS = RMS(1:it);

% if( ISVB), 
%   plot_finalRF( RFP, maxabslag, idx1, idx2 );
% end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_progress( ntin,R,W,lags,RW,RFP,U,UP )

clf;

subplot(4,1,1); plot(1:ntin,R,'-k'); hold on; 
plot(1:ntin,U,'--k'); hold on; 
plot(1:ntin,W,'-r'); 
legend('Residual Numerator','Num','Denominator');
legend boxoff;

subplot(4,1,2); plot(lags,RW,'-k'); hold on;
legend('X-Correlation Function');
legend boxoff;

subplot(4,1,3); plot(lags,RFP,'-k'); hold on;% plot(i1,P(i1),'rx');
legend('Predicted RF');
legend boxoff;

subplot(4,1,4); plot(1:ntin,U,'-k'); hold on; plot(1:ntin,UP,'-r');
legend('Numerator','Predicted Numerator');
legend boxoff;
input('Press a key to continue');

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_finalRF( RF, maxabslag, idx1, idx2 )
clf;
plot( -maxabslag:1:maxabslag, RF ); hold on;
plot( (-maxabslag+idx1-1):1:(-maxabslag+idx2-1), RF(idx1:idx2), '--r');

axis tight;
input('Press a key to continue');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% makeRFitdecon.m ends here
