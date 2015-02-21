function [SEIS, T] = chopSeis( SEIS, T, T1, T2 )
% 
% [SEIS, T] = chopSeis( SEIS, T, T1, T2 )
% 
% Chop the seismograms so only T1 <= t <= T2 are included
%
% In: 
% SEIS = Seismogram array (NT x NC), 1 column for each component.  
% T = the times of the samples in  SEIS in s
% T1 = the new start time
% T2 = the new end time
%
% Out:
% SEIS = seismogram array after chop
% T = new time
%

% chopSeis.m --- 
%  
%  Filename: chopSeis.m
%  Author: Iain Bailey
%  Header Created: Thu Nov 17 15:04:23 2011 (-0800)
%  Version: 1
%  Last-Updated: Thu Nov 17 15:09:06 2011 (-0800)
%            By: Iain Bailey
%      Update #: 8
%  
%----------------------------------------------------------------------
%  
% Change Log:
%  Thu Nov 17 2011 : Corrected error reporting
%  
%  
% Code:


if( T(1) > T1 ), 
  fprintf('Warning: Requested chop before %.2f, but time at trace start is %.2f\n',...
	  [T1, T(1)] );
end
if( T(end) < T2 ),
  fprintf('Warning: Requested chop after %.2f, but time at trace end is %.2f\n',...
	  [T2, T(end)] );
end

keepIdx = find( T >= T1 & T <= T2 );

SEIS = SEIS( keepIdx, : );
T = T(keepIdx);


return

%----------------------------------------------------------------------
%  
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
%----------------------------------------------------------------------
% chopSeis.m ends here
