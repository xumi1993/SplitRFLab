function SL_showparticlemotion(fig,seis)
% show the particle motion in selected time window

global thiseq



h = findobj('Type','Figure', 'Name','Particle motion');
if isempty(h)
    h    = figure('Name','Particle motion','Position',[ 10 100 200 200],'NumberTitle','off','MenuBar','none','color','w');
    colormap(copper)
else
    clf(h)
end

figure(h)
axes('units','Normalized', 'Position',[.13 .13 .77 .77], 'Box', 'On',  'XLim', [-1 1], 'yLim', [-1 1], 'Xtick',[-1 0 1], 'Ytick',[-1 0 1])

if ~isfield(thiseq,'a')
    return
end

o         = thiseq.Amp.time(1);
ia = floor((thiseq.a-o)/thiseq.dt);
ib = ceil((thiseq.f-o)/thiseq.dt);

if strcmp(thiseq.system,'ENV')
    x = get(seis(1),'Ydata');  x = x(ia:ib);
    y = get(seis(2),'Ydata');  y = y(ia:ib);
     xlabel(get( get( get(seis(2),'Parent'),'Ylabel'), 'String'))
    ylabel(get( get( get(seis(1),'Parent'),'Ylabel'), 'String'))
    
    X = sin(thiseq.bazi/180*pi);
    Y = cos(thiseq.bazi/180*pi);   
else
    x = get(seis(2),'Ydata');  x = x(ia:ib);
    y = get(seis(1),'Ydata');  y = y(ia:ib);
    xlabel(get( get( get(seis(2),'Parent'),'Ylabel'), 'String'))
    ylabel(get( get( get(seis(1),'Parent'),'Ylabel'), 'String'))
    X = 0;
    Y = 1;
end

%% backazimuth:

plot( [-X X], [-Y Y], 'k:' )


m = max(abs([x, y]));
xx =x'/m;
yy =y'/m;
patch('Faces',1:length(y)+1,'Vertices',[xx yy;nan nan],'FacevertexCdata' ,(1:length(y)+1)','facecolor','none','edgecolor','interp')


if strcmp(thiseq.system,'ENV')
    xlabel(get( get( get(seis(1),'Parent'),'Ylabel'), 'String'))
    ylabel(get( get( get(seis(2),'Parent'),'Ylabel'), 'String'))   
else
    xlabel(get( get( get(seis(2),'Parent'),'Ylabel'), 'String'))
    ylabel(get( get( get(seis(1),'Parent'),'Ylabel'), 'String'))
end
set(gca, 'XLim', [-1 1], 'yLim', [-1 1], 'Xtick',[], 'Ytick',[],'DataAspectRatio',[1 1 1])

figure(fig)

%% This program is part of SplitLab
% © 2006 Andreas Wüstefeld, Université de Montpellier, France
%
% DISCLAIMER:
% 
% 1) TERMS OF USE
% SplitLab is provided "as is" and without any warranty. The author cannot be
% held responsible for anything that happens to you or your equipment. Use it
% at your own risk.
% 
% 2) LICENSE:
% SplitLab is free software; you can redistribute it and/or modifyit under the
% terms of the GNU General Public License as published by the Free Software 
% Foundation; either version 2 of the License, or(at your option) any later 
% version.
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
% more details.