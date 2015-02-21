function hdr = shiftSacHdrTimes( hdr, dt )
% Add dt to all times in the sac header 
%
% hdr = shiftSacHdrTimes( hdr, dt )
%
% IN
% hdr = sac hdr (see sachdr.m)
% dt = amount to ADD to each value
%
% OUT:
% hdr = modified sac header

%--- shiftSacHdrTimes.m --- 
%  
%  Filename: shiftSacHdrTimes.m
%  Author: Iain Bailey
%  Created: Mon May  9 16:48:11 2011 (-0700)
%  Last-Updated: Sun Jun 26 09:47:53 2011 (-0700)
%            By: Iain William Bailey
%      Update #: 7
%  Compatibility: Matlab 7.12.0.635 (R2011a)
%  

%--- Commentary: 
%  
%  
%  

%--- Change Log:
%  
%  
%  

%--- Code:

% remove from all of the header values that don't have default vals
if( hdr.times.o ~= -12345 ), hdr.times.o = hdr.times.o + dt; end
if( hdr.times.b ~= -12345 ), hdr.times.b = hdr.times.b + dt; end
if( hdr.times.e ~= -12345 ), hdr.times.e = hdr.times.e + dt; end
if( hdr.times.a ~= -12345 ), hdr.times.a = hdr.times.a + dt; end
for i=1:10,
  if( hdr.times.atimes(i).t ~= -12345 ), 
    hdr.times.atimes(i).t = hdr.times.atimes(i).t + dt; 
  end
end

return 

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
%--- shiftSacHdrTimes.m ends here
