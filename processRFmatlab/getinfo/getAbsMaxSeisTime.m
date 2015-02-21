function [a, idx, tmax] = getAbsMaxSeisTime( SEIS, TIME, T1, T2 );
%
% [a, idx, tmax] = getAbsMaxSeisTime( SEIS, TIME )
% [a, idx, tmax] = getAbsMaxSeisTime( SEIS, TIME, T1, T2 )
%
% Description: 
% Find the max of a seismogram between t1 and t2 or in all times
%
% IN:
% SEIS = single seismogram array
% TIME = times corresponding to each of the points in SEIS
% T1 = the time from which to search
% T2 = the time until which to search

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Author: Iain W Bailey
%% Maintainer: 
%% Created: Wed Oct 20 15:06:34 2010 (-0700)
%% Version: 
%% Last-Updated: Wed Oct 20 16:02:41 2010 (-0700)
%%           By: iwbailey
%%     Update #: 29
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%%% Change Log:
%% 
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Error check
if length( SEIS )~=length(TIME),
  error( ['getMaxTime: expected seismogram and time arrays to have', ...
	  ' same size.  Actually seis: %i and time: %i '],...
	 [length(SEIS),length(TIME)] );
end

% check times
if nargin < 4 || T2 > max(TIME),
  T2 = max(TIME);
end
if nargin < 3 || T1 < min(TIME),
  T1 = min(TIME);
end
if( T2 < min(TIME) ),
  error('getMaxTime: T2 must be greater than start of Rfn')
end
if( T1 > max(TIME) ),
  error('getMaxTime: T1 must be less than end of Rfn')
end
if T2 < T1, 
  tmp=T2; T2=T1; T1=tmp; clear tmp;
end

% get the indices of times we want
idxs = find( TIME>T1 & TIME< T2 );

% get max val
[a idx1] = max( abs( SEIS(idxs) ) );

% index in original array
idx=idxs(idx1);

% get the time at which the max time ends
tmax=TIME(idx);


return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% getAbsMaxSeisTime.m ends here
