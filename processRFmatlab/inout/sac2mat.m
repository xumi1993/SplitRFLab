function [t,data,SAChdr] = sac2mat(filename)
% Read little endian sac into matlab. 
%
% [t,data,SAChdr] = sac2mat(filename)
%
% Read little endian sac into matlab. 
% This is a modification of the fget_sac.m, written by Zhigang Peng.  
% 
% In:
%  filename = string of the sac file to be read in 
%
% Out:
%  t = time array
%  data = amplitudes of the trace
%  SAChdr = header information as a class object, see sachdr.m

%--- sac2mat.m --- 
%  
%  Filename: sac2mat.m
%  Author: Zhigang Peng
%  Maintainer: Iain Bailey 
%  Created: ???
%  Version: 
%  Last-Updated: Sun Jun 26 09:33:21 2011 (-0700)
%            By: Iain William Bailey
%      Update #: 3
%  Compatibility: 
%  
% ----------------------------------------------------------------
%  
%--- Change Log:
%  
%  
% ----------------------------------------------------------------
%--- Code:

if nargin <1, 
  error('sac2mat: ERROR Input file name not specified'); 
end

% get the headers and data in arrays
[head1, head2, head3, data] = sac( filename );

% turn the header arrays into a single class structure
[SAChdr] = sachdr( head1, head2, head3 );

% check if the number of points makes sense
% TODO better way of checking needed
if( SAChdr.trcLen > 1e9 ),
  error(['ERROR: Seems like you tried to open a big endian file (%s).'...
	 '\n...Try sacswap on your data'], filename )
end

% make the time array
t = SAChdr.times.b + SAChdr.times.delta*(0:(SAChdr.trcLen-1));
return

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % sac2mat.m ends here
