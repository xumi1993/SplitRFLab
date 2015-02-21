function [eseis, nseis, zseis, hdr] = read3seis(efile,nfile,zfile)

% Read in three sac files showing 3 components of the same seis, make a single header
%
% [eseis, nseis, zseis, hdr] = read3seis(efile,nfile,zfile)
% 
% IN:
% efile,nfile,zfile = name of 3 sac files for the east, north and z components
%              (could actually be any three components)
%
% OUT:
% eseis,nseis,zseis = amplitudes of seismograms in each of the components
% hdr = sac header information amalgamated 

%-- read3seis.m --- 
%  
%  Filename: read3seis.m
%  Author: Iain William Bailey
%  Created: Sun Jul  3 23:40:59 2011 (-0700)
%  Version: 1
%  Last-Updated: Sun Jul  3 23:43:05 2011 (-0700)
%            By: Iain William Bailey
%      Update #: 3
%  Compatibility: 
%  
%----------------------------------------------------------
%  
%-- Change Log:
%  
%  
%----------------------------------------------------------
%  
%-- Code:

% Read in the files and sac headers
try 
  [te, eseis, ehdr] = sac2mat( efile );
catch ME
  disp('****Problem Reading file****'); disp(ME.message)
  error( 'Error reading E component file %s', efile )
end
try 
  [tn, nseis, nhdr] = sac2mat( nfile );
catch ME
  disp('****Problem Reading file****'); disp(ME.message)
  error( 'Error reading N component file %s', nfile )
end
try 
  [tz, zseis, zhdr] = sac2mat( zfile );
catch ME
  disp('****Problem Reading file****'); disp(ME.message)
  error( 'Error reading Z component file %s', zfile )
end

% check the headers are consistent
[hdr, t, eseis, nseis, zseis] = combineHeaders( ehdr, eseis, nhdr, nseis, zhdr, zseis );


return
%----------------------------------------------------------
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
%----------------------------------------------------------
%-- read3seis.m ends here
