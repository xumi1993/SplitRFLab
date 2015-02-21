function lims = plot3seis( t1, a1, t2, a2, t3, a3, varargin )
% plot3seis( t1, a1, t2, a2, t3, a3, [struct(...)])
%
% Plot three components using same scale for time and amplitude on
% currently active figure
%
% IN :
% t1,t2,t3 = times of 1st, 2nd, 3rd component
% a1, a2, a3 = amplitudes of 1st, 2nd, 3rd comonent
%
% IN(OPTIONAL - pass as a structure):
% 'clabs', clabs = labels for each of the components (e.g., ['Z';'R';'T'] )
% 'ltype', ltype = e.g., '-k' to plot black line
% 'times', times = arrival times to mark
% 'labels', labels = names of each of the arrival times
% 'lims', lims = min,max regions of plot [t0,t1,a0,a1]

%--- plot3seis.m --- 
% 
% Filename: plot3seis.m
% Author: Iain Bailey
% Created: Tue Mar  1 11:16:57 2011 (-0800)
% Version: 1
% Last-Updated: Thu Nov 17 19:24:22 2011 (-0800)
%           By: Iain Bailey
%     Update #: 94
% Compatibility: Matlab R2009a
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%--- Change Log:
% Thu Nov 17  2011:  created option for nargin < 7
% Thu Sep  1 09:53:21 2011 : Added option to change line type
% Tue Mar 29 12:09:05 2011 (-0700): Changed order of input arguments
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%--- Code:

% deal with variable arguments
% plot limits
if nargin < 7 ,
  argstruct = struct();
else
  argstruct = varargin{1};
end

if( isfield( argstruct, 'lims' ) ),
  lims = argstruct.lims;
else
  ttt = [ t1, t2, t3 ];  aaa = [ a1, a2, a3 ];
  lims = [ min( reshape( ttt , numel(ttt), 1) ), ...
	   max( reshape( ttt , numel(ttt), 1) ), ...
	   min( reshape( aaa, numel(aaa), 1) ), ...
	   max( reshape( aaa, numel(aaa), 1) ) ];
end

% legend labels
if( isfield( argstruct, 'clabs' ) ), clabs = argstruct.clabs;
else clabs = ['Z'; 'N'; 'E']; % default labels
end

% line type
if( isfield( argstruct, 'ltype' ) ), ltype = argstruct.ltype;
else ltype = '-k'; 
end

% plot dimensions
w=0.8; % width of the plots
h=0.26; % height of each plot
dh=0.02; % spacing between subplots
xpos=0.1; % position of origin of lowest plot
ypos=0.1;

% plot z component
subplot('Position',[xpos,ypos+2*(h+dh),w,h]); hold on;

% plot the arrival times 
if( isfield( argstruct, 'times' ) & isfield( argstruct, 'labels' ) ),
  plotarrtimes( argstruct.times, argstruct.labels, lims(3), lims(4) );
end

% plot the trace
plot( t1, a1 , ltype); 
legend( clabs(1,:) ); legend boxoff
% set constant limits
axis( lims );
grid on;
% remove x tick labels
set(gca,'xticklabel',{''},'XMinorTick', 'on');

% repeat for 2nd  component
subplot('Position',[xpos,ypos+h+dh,w,h]); hold on;
if( isfield( argstruct, 'times' ) & isfield( argstruct, 'labels' ) ),
  plotarrtimes( argstruct.times, argstruct.labels, lims(3), lims(4) );
end
plot( t2, a2 ,ltype ); 
legend( clabs(2,:) ); legend boxoff
axis( lims )
grid on;
set(gca,'xticklabel',{''},'XMinorTick', 'on');

% plot n component
subplot('Position', [xpos,ypos,w,h]); hold on;
if( isfield( argstruct, 'times' ) & isfield( argstruct, 'labels' ) ),
  plotarrtimes( argstruct.times, argstruct.labels, lims(3), lims(4) );
end
plot( t3, a3 , ltype); 
legend( clabs(3,:) ); legend boxoff
axis( lims )    
grid on;
set(gca,'xtickMode', 'auto','XMinorTick', 'on');
xlabel('Time (s)');
return 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotarrtimes(times, labels, amin, amax)

% plot the arrival times of different phases and labels

for i=1:length(times),
  plot( [times(i) times(i)], [amin,amax], '-r' );
  text( times(i), amin, labels(i,:) ,'Rotation',45);
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; see the file COPYING.  If not, write to
% the Free Software Foundation, Inc., 51 Franklin Street, Fifth
% Floor, Boston, MA 02110-1301, USA.
% 
%%% plot3seis.m ends here
