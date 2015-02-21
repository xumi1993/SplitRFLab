% -- plot2Rfn.m --- 
function plot2Rfn( TIME, SEIS1, SEIS2 , LABEL1, LABEL2, LTYPE1, LTYPE2 )
% plot2Rfn( 
% plot2Rfn( 
%
% Plot two receiver functions for the same time axis overlaying
% each other. Designed to compare the Z and the T receiver functions
% 
% IN:
% TIME = time of samples
% SEIS1 = amplitudes 1st of seismograms
% SEIS2 = amplitudes 2nd of seismograms
% LABEL = label to identify the plot
% LTYPE = string representing plot type

% 
% Filename: plot2Rfn.m
% Author: Iain W. Bailey
% Created: Thu Nov 11 09:05:57 2010 (-0700)
% Version: 1
% Last-Updated: Thu Nov 11 09:33:13 2010 (-0800)
%           By: iwbailey
%     Update #: 46
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Change Log:
% 
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

%- Code:

clf;

if( nargin < 5 ),
  LTYPE1 = '-k';
  LTYPE2 = '-b';
end

try,
  plot(TIME, SEIS1 ,LTYPE1); hold on
  plot(TIME, SEIS2 ,LTYPE2); 
catch ME
 % fprintf('Line types incorrectly specified: %s, %s. Switching to default\n',...
%	  [LTYPE1,LTYPE2] )
  plot(TIME, SEIS1 ,'-k'); hold on;
  plot(TIME, SEIS2 ,'-b');  
end

legend(LABEL1,LABEL2)
legend boxoff;
axis tight;
xlabel('Time (s)');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot2Rfn.m ends here
