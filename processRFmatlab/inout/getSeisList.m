function [seislist, stIdx, nsta] = getSeisList( files )
% Read in a list of sac structures from an array of matlab structures 
%
% [seislist, stIdx, nsta] = getSeisList( files )
%
% From a list of sac filenames, read each file in and create an array of matlab 
% structures
%
% IN:
% files = cell array of filenames such that files{1} is the first filename
%
% OUT:
% seislist = array of seis structures. Each element contains sac header information 
%          (e.g., seislist(1).times.tb, etc.  see sachdr) in addition to the fields...
%          seislist(i).seis = the seismogram
%          seislist(i).t = the times for the seismogram
%          seislist(i).filename = the filename read in
% 
% stIdx = the station index for each entry in seislist (arbitrary integer assigned to
%         each station read in)
%
% nsta = the total number of stations read in
% 

%-- getSeisList.m --- 
% 
% Filename: getSeisList.m
% Author: Iain Bailey
% Created: Wed May 25 08:36:25 2011 (-0700)
% Version: 1
% Last-Updated: Tue Aug 23 14:35:10 2011 (-0700)
%           By: Iain Bailey
%     Update #: 20
% Compatibility: Matlab 2011a
% 
%------------------------------------------------------------
%  
%--  Change Log:
%  
%  
%  
%--  Code:

% open all files, extract the rf data we want into structures
nrf = length(files);

if(nrf<=0), error('getSeisList: No files in list');
end

% loop through all 
jrf = 1;
for irf = 1:nrf,
  
% get file name
  filename=files{irf};

  % read in file
  try 
    [t, seis, hdr] = sac2mat(filename);
    
    % incorporate new data fields
    hdr.t = t;
    hdr.seis = seis;
    hdr.filename = filename;
    
    % get the station name for identifying unique stations
    stationNames(jrf,:) = hdr.station.kstnm;
    
    % append to the list
    seislist(jrf) = hdr;
    jrf = jrf +1;

  catch ME
    % process errors in the input
    disp(ME.message)
    input('Waiting for input to continue')
    continue
  end

end

% get unique number of stations and indices
[ staNm tmpi, stIdx ]  = unique( stationNames , 'rows');
nsta = size( tmpi, 1 );

return
%------------------------------------------------------------
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
%------------------------------------------------------------
%--  getSeisList.m ends here
