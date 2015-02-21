function [SNR,RMSN] = estimateSNR( SEIS, TIME, T1S, T2S, T1N, ...
					   T2N, ISPLOT )
%
% Read a seismogram, estimate the signal to noise ratio.
%
% In:
% SEIS = single column array of seismogram
% TIME = associated times of seismogram samples 
% T1S = Time to consider as start of signal (s)
% T2S = Time to consider as end of signal (s)
% T1N = Time to consider as start of noise (s)
% T2N = Time to consider as end of noise (s)
% ISPLOT = True to plot results and pause
%
% Out:
% SNR = ratio of mean square amplitude for two time parts
% RMSN = root mean square noise between T1N and T2N

%%% estimateSNR.m --- 
%% 
%% Filename: estimateSNR.m
%% Description: Compute the SNR from power around P rel to before
%% Author: Iain W Bailey
%% Maintainer: 
%% Created: Thu Oct 21 07:53:30 2010 (-0700)
%% Version: 
%% Last-Updated: Thu Nov 17 19:31:40 2011 (-0800)
%%           By: Iain Bailey
%%     Update #: 89
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%%% Change Log:
%% 
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%%% Code:
if( nargin < 7 ), ISPLOT = false; end


% check for overlap
if( T2N > T1S ),
  fprintf(['estimateSNR: T2N (%f) should be less than T1S (', ...
	   '%f). Setting equal.\n '], [T2N, T1S] );
  T1S = T2N;
end

% check times are within bounds
if( T2N <= TIME(1) || T1S <= TIME(1) ),
  error(['estimateSNR: Times (%f-%f,%f-%f) not consistent ', ...
	 'with start of trace %f.\n'], [T1S, T2S, T1N, T2N, TIME(1)])
end
if( T1N < TIME(1) )
 T1N = TIME(1);
end
if( T2S > TIME(end) )
 T2S = TIME(end);
end

% get signal 
sig = SEIS( TIME > T1S & TIME <= T2S ); 

% get noise
noi = SEIS( TIME > T1N & TIME <= T2N ); 

if( ISPLOT ),
  plot(TIME,SEIS,'-k'); hold on;
  plot(TIME(TIME > T1S & TIME <= T2S), sig,'--r');
  plot(TIME(TIME > T1N & TIME <= T2N), noi,'--b');
end

% get the average power
sigpow = sum( sig.^2 )./length(sig);
noipow = sum( noi.^2 )./length(noi);

SNR = sigpow / noipow;
RMSN = sqrt( noipow );

return 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% estimateSNR.m ends here
