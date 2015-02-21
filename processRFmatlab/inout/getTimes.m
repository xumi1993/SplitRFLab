function [t, dt, times, labels] = getTimes( head )
% Extract the timing information from the sac style header structure 
%
%[t, dt, times, labels] = getTimes( head )
%
% From a sac header output by sachdr.m , get the sample times,
% arrival times and associated labels
%
% IN: 
% head = header output by sacsun2mat
%
% OUT:
% t = array of times corresponding to the seismogram (s)
% dt = sample interval
% times = array of arrival times in the t0,t1,...t9 
% labels = names corresponding to each of the arrival times in a vertically 
% concatenated array
%

t0 = head.times.b; % time of 1st sample
dt = head.times.delta; % sample interval
nt = head.trcLen; % number of samples

t = t0 + dt*(0:1:(nt-1)); % time vector

% arrival times
times = [ head.times.atimes(:).t ];

% corresponding labels

labels = strvcat( head.times.atimes(1).label, ...
		  head.times.atimes(2).label, ...
		  head.times.atimes(3).label, ...
		  head.times.atimes(4).label, ...
		  head.times.atimes(5).label, ...
		  head.times.atimes(6).label, ...
		  head.times.atimes(7).label, ...
		  head.times.atimes(8).label, ...
		  head.times.atimes(9).label, ...
		  head.times.atimes(10).label );  		  

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%