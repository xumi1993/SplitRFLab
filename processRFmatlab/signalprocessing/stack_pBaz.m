function [times, pmid, bazmid, seiss, stds, counts] = ...
    stack_pBaz( timelst, seislst, plst, bazlst, dp, dbaz, type )
% stack_pBaz : bin based on back azim and slowness then stack a bunch of seismograms
% 
%  [time, pmid, bazmid, seiss, stds] = ...
%    stack_pBaz( timelst, seislst, plst, bazlst, dp, dbaz, type)
%
% IN: 
% timelst = cell array of times for each seis
% seislst = cell array of amplitudes for each seis
% plst = regular array of slowness values for each seis 
% bazlst = reg. array of back azimuth values for each seis
% dp = bin interval to use for slowness, starts at zero
% dbaz = bin interval to use for back azimuth, starts at zero, adjusted 
%        for integer amount within circle
% type = 'linear' or 'phase'
% 
% OUT:
% time = [1 x nt] common time array of all stacked seismogram
% pmid = [1 x nstk] mid points of slowness for each bin
% bazmid = [1 x nstk] mid points of back azimuth for each bin
% seiss = [nstk x nt] stacked seismograms for each bin
% stds = [nstk x nt] estimate of the standard deviation at each time for 
% counts = [1 x nstk] number in each stack

%-- stack_pBaz.m --- 
%  
%  Filename: stack_pBaz.m
%  Description: 
%  Author: Iain Bailey
%  Maintainer: 
%  Created: Wed Aug 10 10:39:52 2011 (-0700)
%  Version: 
%  Last-Updated: Tue Aug 30 15:37:17 2011 (-0700)
%            By: Iain Bailey
%      Update #: 160
%  Compatibility: 
%  
%--------------------------------------------------
%  
%-- Change Log:
%  Thu Aug 25 2011 - use cell arrays for output of times and seis
%  
%--------------------------------------------------
%
%-- Code:

% default is linear stacking
if( nargin < 7 ), type = 'linear'; end

ns = numel(seislst); % number of traces

% Check for errors
if( ns ~= numel(timelst ) ),
  error( 'stack_pBaz: Time and seis arrays dont have the same number of elements' )
end

if( ns == 0),
  error('stack_pBaz: No traces in list\n');
  return 
end

if( ns ==1 ),
  % one trace so return it
  times = timelst;
  nt = numel(times{1});
  pmid = 0.5*dp*( ceil( plst/dp ) + floor( plst/dp ) );
  bazmid = 0.5*dbaz*( ceil( bazlst/dbaz ) + floor( bazlst/dbaz ) );
  seiss = seislst;
  stds = zeros(1,nt); % initial std array
  counts = 1;
  return
end

% get bin intervals
dbaz = 360/round( 360 / dbaz );
edgesB = 0:dbaz:360;

pmax = dp*ceil( max( plst )/dp );
edgesP = 0:dp:pmax;

% check orientation of input arrays, should be columns
if( size( bazlst,2) > size( bazlst,1 ) ), bazlst = bazlst'; end
if( size( plst,2) > size( plst,1 ) ), plst = plst'; end

% get the 2-D histogram to find which stacks go where
bazlst=mod(bazlst+360,360);  % make sure angles from 0 to 360
[ ~, binbi ] = histc( bazlst, edgesB);
[ ~, binpi ] = histc( plst ,edgesP);
nums = accumarray( [binbi, binpi], 1, [numel(edgesB)-1, numel(edgesP)-1] );

% get the indices non-empty bins
[idx1, idx2] = find( nums ~= 0 );
nstk = numel( idx1 ); % number of stacks

% get mid points
bazmid = edgesB(idx1)+0.5*dbaz;
pmid = edgesP(idx2)+0.5*dp;

% get empty arrays
seiss = cell(nstk,1); % zeros( nstk, nt );
stds = cell(nstk,1); % zeros(nstk, nt );
times = cell(nstk,1);
counts = zeros(1,nstk);
for istk = 1:nstk,
  
  % find the indices in the original matrix
  idx = find( binbi == idx1(istk) & binpi == idx2(istk) );

  % get time from the first array
  time = timelst{idx(1)};
  
  % stack 
  if( strcmp ( type, 'phase' ) == 1 ),
    % phase weighted stack
    [times{istk}, seiss{ istk }, stds{istk} ] = phwStack( {timelst{idx}}, ...
						  {seislst{idx}}, 1, time ); 
  else
    % linear stack
    [times{istk}, seiss{ istk }, stds{istk} ] = linStack( {timelst{idx}}, ...
						  {seislst{idx}}, time ); 
  end

  % number in each stack
  counts(istk) = nums( idx1(istk), idx2(istk) );
end

return
%--------------------------------------------------
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
%--------------------------------------------------
%-- stack_pBaz.m ends here
