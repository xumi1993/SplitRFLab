function seis=SL_SeismoViewer(idx)
% plot seismograms and provide user interaction
if nargin<1||isempty(idx)
    idx=1;
end

global config eq thiseq 
    
if isempty(eq)
    beep
    errordlg('Sorry no SplitLab-Project is loaded!','No project')
    return
end

config.db_index = idx;
if isfield(thiseq,'SplitPhase')
    oldphase = thiseq.SplitPhase;
else
    oldphase = 'SKS';
end

thiseq = [];
try
    thiseq = eq(idx); %AW; 07.01.06
    thiseq.index=idx;
catch
    thiseq = eq(1); %AW; 07.01.06
    thiseq.index=1;
    config.db_index=1;
end


if isempty([thiseq.seisfiles{:}])
errordlg('No SAC files associated to database!','Files not associated')
    return
end

efile = fullfile(config.datadir, thiseq.seisfiles{1});
nfile = fullfile(config.datadir, thiseq.seisfiles{2});
zfile = fullfile(config.datadir, thiseq.seisfiles{3});
if ~exist(efile,'file')||~exist(nfile,'file')||~exist(zfile,'file')
    errordlg({'Seismograms not found!','Please check data directory',efile,nfile,zfile},'File I/O Error')
   return
end


%% show WorldMap, if on screen
earthfig= findobj('Type','Figure','Tag','EarthView');
if ~isempty(earthfig)
  SL_Earthview(thiseq.lat, thiseq.long, thiseq.Mw, thiseq.depth, thiseq.date(2))
% set(0,'CurrentFigure',seisfig)
%  set(seisfig,'Position',figpos);
end

%% plot defaults
scol = [0 0 1; 1 0 0;0 .8 0];% color ordering of seimogramms
tcol = 'm';  % color of travel time markers
acol = [0.9 0.9 0.9]; % color of active selection area
ocol = [1 1 .8];      % color of old selection area(s)
afcol= [1 1 1] * .6;  %color of SAC header A & F markers
fontsize          = get(gcf,'DefaultAxesFontsize')-3;
thiseq.system     = 'ENV'; % or: 'LTQ'; % DEFAULT SYSTEM
thiseq.SplitPhase = 'SKS'; %default selection

thiseq.resultnumber = length(thiseq.results) + 1;
n = thiseq.resultnumber;

titlestr={sprintf('Event: %s, (%03.0f); Station: %s; E_{SKS}: %4.1f%%',thiseq.dstr, thiseq.date(7), config.stnname, abs(thiseq.energy*100));
    sprintf(['M_w = %3.1f  Backazimuth: %6.2f' char(186) '  Distance: %6.2f' char(186) '   Depth: %3.0fkm'],thiseq.Mw, thiseq.bazi, thiseq.dis, thiseq.depth)};

%% get last used filter
if isfield(thiseq.results,'filter')
    if ~isempty(thiseq.results(end).filter)
        thiseq.filter  = thiseq.results(end).filter;
    else
        thiseq.filter =[0 inf];  % Hz; cut freqency;  here unfiltered
    end
else
    thiseq.filter =[0 inf];  % Hz; cut freqency;  here unfiltered
end



%%   figure initalisation
seisfig = findobj('Tag','SeismoFigure');
figname = sprintf('Preview(%.0f/%.0f): start= %.3fHz  stop= %0.2f Hz', config.db_index, length(eq),thiseq.filter );
if isempty(seisfig)
    pos=get(0,'ScreenSize');
    width= pos(3)-10 ; height=pos(4)/2;
    xpos = pos(1) +5;  ypos = height - 100 ;
    figpos =[xpos ypos width height];
    seisfig = figure('NumberTitle','off',...
        'name',figname,...
        'renderer','painters',...
        'ToolBar','none',...
        'Menubar','none',...
        'Tag','SeismoFigure',...
        'color','w',...
        'Position',figpos,...
        'Pointer','crosshair', ...
        'PaperType',       config.PaperType,...
        'PaperOrientation','landscape',...
        'PaperUnits','centimeters');
else
   figure(seisfig); %bring window to front
    figpos   = get(gcf,'Position');
    clf(seisfig) 
    set(seisfig,'name',figname,'Tag','SeismoFigure','Pointer','crosshair',...
        'WindowButtonDownFcn','',  'PaperOrientation','landscape')
end

orient landscape


%% STATUSBAR AND PHASE SELECTOR MENU
val   = strmatch(oldphase, thiseq.phase.Names);
if isempty(val);    val=1;  end
thiseq.SplitPhase     = thiseq.phase.Names{val(1)};
if isempty(thiseq.phase.inclination)
    thiseq.phase.inclination=0;
end
thiseq.tmpInclination = thiseq.phase.inclination(val(1));

phaseMenu = uicontrol('style', 'PopupMenu','Units', 'pixel',...
    'Position', [2 1 60 17],'String', thiseq.phase.Names,...
    'Value',val(1),'HorizontalAlignment','right',...
    'Tag','PhaseSelector');

status = uicontrol('style', 'Text','BackGroundColor','w',...
    'Units', 'pixel','Position', [62 2 figpos(3)/3 14],...
    'String', '  Status:   Reading seismograms ...', 'HorizontalAlignment','left',...
    'Tag','Statusbar');

drawnow
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% READ SEISMOGRAMS AND ROTATE                                         % 
   thiseq  = readseis3D(config,thiseq);                                %
   if isfloat(thiseq), SL_SeismoViewer(thiseq); return,end
   val     = get(findobj('Tag','PhaseSelector'),'Value');              %
   inc     = thiseq.phase.inclination(val);                            %
   
   M = rot3D(inc, thiseq.bazi); %the rotation matrix                   %

   ZEN = [thiseq.Amp.Vert, thiseq.Amp.East, thiseq.Amp.North]';         %
   LQT = M * ZEN; %rotating                                            %
   
   thiseq.Amp.Ray    = LQT(1,:);                                       %
   thiseq.Amp.Radial = LQT(2,:);                                       %
   thiseq.Amp.Transv = LQT(3,:);
   
% roate to R-T-Z
   RTZ = rotateSeisENZtoTRZ( [thiseq.Amp.East, thiseq.Amp.North, thiseq.Amp.Vert] , thiseq.bazi );
   thiseq.Amp.T = RTZ(:,1);
   thiseq.Amp.R = RTZ(:,2);
   thiseq.Amp.Z = RTZ(:,3);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Axes:
    s = findobj('Tag','Statusbar');
    set(s,'String', 'Status:  Drawing axes ...');drawnow

pos      = [.1 .63 .85 .25;   .10 .36 .85 .25;   .1 .09 .85 .25]; %position of axis
bigpos   = [pos(3,1:3) pos(1,4)+pos(1,2)-pos(3,2)]; %exactly the size of the 3 seismograms


% TRAVEL TIMES
% are plotetd in an invisible axes, so we only have to plot them once...
subax(4)  = axes('position',bigpos, 'Parent', seisfig, 'Xlim',[thiseq.Amp.time(1) thiseq.Amp.time(end)],'Tag','TTimeAxes', 'XMinorTick','On');
%original SAC markers
    x = [thiseq.SACpicks(1) thiseq.SACpicks(1)  nan thiseq.SACpicks(2) thiseq.SACpicks(2) ];
    line(x, [0 1 nan 0 1], 'Color',afcol, 'LineStyle','-', 'Parent',subax(4));
    text(thiseq.SACpicks, [1 1], {' A' , ' F'},...
        'Color',afcol, 'FontSize',fontsize+1,...
        'VerticalAlignment','top', 'HorizontalAlignment','left', 'Parent',subax(4));
    
    
% plot traveltimes
for i=1:length(thiseq.phase.ttimes)
    tt = thiseq.phase.ttimes(i);
    line([tt tt], [0 1], 'Color',tcol, 'LineStyle',':', 'Tag','TTime', 'Parent',subax(4));
    text(tt,0,[' ' thiseq.phase.Names{i}],...
        'Color',tcol, 'FontSize',fontsize+1, 'rotation',90, 'Tag','TTime',...
        'VerticalAlignment','top', 'HorizontalAlignment','left', 'Parent',subax(4));
end

% SEISMOGRAM AXES
for i=1:3
    subax(i)=axes('units','normalized', 'Position',pos(i,:), 'box','on',...
        'FontSize',fontsize,'FontName','Times', 'XMinorTick','On', 'Parent', seisfig);
    seis(i) = plot(thiseq.Amp.time, thiseq.Amp.time,'Color', scol(i,:),'Tag','seismo', 'Parent',subax(i));%dummy seismogram, initimlies size
end
xlabel(sprintf('seconds after %02.0f:%02.0f:%05.3f',thiseq.date(4:6)));
set(subax(1:2),'XTickLabel',[])
set(subax,'Tag','seisaxes')
% Link all 4 X-axis
set(subax,'color','none','YLimMode','auto', 'XMinorTick','On','TickLength',[0.007 0.025],...
        'Xlim',[thiseq.Amp.time(1) thiseq.Amp.time(end)], 'Parent', seisfig)
        
SL_updatefiltered(seis); %plot seismogramms

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% LINKING of axes
link_obj = linkprop(subax,{'Xlim','Xgrid','Ygrid'});
setappdata(subax(4),'dummy',link_obj);

%% Initialise time selector area
% based on "gline.m" of statistics toolbox
% is at first invisible (area == 0)
hold(subax(4),'on')
split.x = [];
split.index=idx;
%old windows
for n = 1: thiseq.resultnumber-1
    x = [thiseq.results(n).a thiseq.results(n).a thiseq.results(n).f thiseq.results(n).f];
    fill(x, [0 1 1 0], ocol,...
        'Parent',subax(4), ...
        'EdgeColor','none', ...
        'Visible','on',...
        'Tag','SplitWindow');
%     c = get(subax(4),'children'); set(subax(4),'Children',[c(2:end) ;c(1)]);
end
%new (active) window
x = [0 0 0 0];
split.hfill = fill(x, [0 1 1 0], acol,...
    'Parent',subax(4),...
    'EdgeColor','none',...
    'Visible','on',...
    'Tag','SplitWindow');
 c = get(subax(4),'children');
 r=thiseq.resultnumber+1;
 order = [c(r:end) ;c(1:r-1)];
 set(subax(4),'Children',order)





%% FINAL beautify

set(subax(4),'visible','off')
title(subax(4),titlestr,'visible','on')
ylabel(subax(4), sprintf('f_1 = %4.3f Hz   f_2 = %4.3f Hz',thiseq.filter),...
    'Tag','TTimeAxesLable','HandleVisibility','on',...
    'Units', 'normalized','Position', [1.03 .5 1], 'visible','on','FontSize',fontsize)
set(seisfig, ...
    'WindowButtonDownFcn', {@buttonDown,split,subax(4), seis}, ...
    'KeyPressFcn',         {@seisKeyPress, seis});
hold off
set(phaseMenu, 'Callback', {@RotatePhaseSelect,seis},'KeyPressFcn', '' )
seisfigbuttons(seisfig,seis);
set(subax,'Xlim',[thiseq.Amp.time(1) thiseq.Amp.time(end)])
s = findobj('Tag','Statusbar');
set(s,'String', 'Status: ');
drawnow;






%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                         S U B F U N C T I O N S                      %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RotatePhaseSelect(src,evt,seis)
global thiseq
figure(gcbf); % Changes the focus to the figure so that the menu box loses focus
drawnow;      % go on with callback 

val     = get(src,'Value');
inc     = thiseq.phase.inclination(val);
thiseq.SplitPhase = char(thiseq.phase.Names(val));

M = rot3D(inc, thiseq.bazi); %the rotation matrix 

ZEN = [thiseq.Amp.Vert, thiseq.Amp.East, thiseq.Amp.North]';
LQT = M * ZEN; %rotating
thiseq.Amp.Ray    = LQT(1,:); 
thiseq.Amp.Radial = LQT(2,:);
thiseq.Amp.Transv = LQT(3,:);


SL_updatefiltered(seis);
s = findobj('Tag','Statusbar');
set(s,'String', sprintf(['Status:  Inclination = %4.2f' char(186)], thiseq.phase.inclination(val)));
thiseq.tmpInclination = thiseq.phase.inclination(val);


%% ========================================================================
function buttonDown(src, evnt, split, ax, seis )
Pt1 = get(ax,'CurrentPoint');
xxx = xlim;
if Pt1(1) < xxx(1) || Pt1(1) > xxx(2)
    return
else
    split.x = [Pt1(:,1); Pt1(:,1)];
    set(split.hfill,'Xdata',split.x,'Visible','on');
%    split.hfill.FaceAlpha = 0.5;
    drawnow expose
%    animatedline(split.x(1:2),split.x(3:4),'Color','r');
    set(src,'pointer','left','WindowButtonMotionFcn',{@buttonMotion, split, ax, seis});
end

%========================================================================
function buttonMotion(src, evnt, split, ax, seis)
Pt2 = get(gca,'CurrentPoint');
Pt2 = [Pt2(:,1)];
split.x(3:4) = Pt2;
split.x      = sort(split.x);
set(split.hfill,'Xdata',split.x);
split.hfill.FaceAlpha = 0.5;
drawnow expose
set(src,'WindowButtonupFcn',{@buttonUp, split, ax, seis})
status = findobj('Tag','Statusbar');
set(status,'String',sprintf('Split Window: %11.2fsec -- %.2fsec',split.x(1),split.x(3)));drawnow







%% ========================================================================
function buttonUp(src, evnt, split, ax, seis)
global thiseq

set(src,'WindowButtonMotionFcn','','Pointer','crosshair');
if abs(diff(split.x(2:3))) < diff(xlim)/500 % 0.5precent of total axes length
    beep
    status=findobj('Tag','Statusbar');
    set(status,'String','time window less than 1% of window length! Canceling area selection');drawnow
    if ishandle(split.hfill)
        set(split.hfill,'Xdata',[0 0 0 0])
    end

else
    xxx = xlim;
    if split.x(1) < xxx(1) || split.x(4) > xxx(2)
        return
    else
        if ishandle(split.hfill)
            set(split.hfill,'Xdata',split.x);
            split.hfill.FaceAlpha = 0.5;
            drawnow expose
            n = thiseq.resultnumber;
            thiseq.a     = split.x(2); %start of window
            thiseq.f     = split.x(3); %end of window
        end
    end
end
pb = findobj('Tag','ParticleButton');
if strcmp(get(pb,'State'), 'on')
    SL_showparticlemotion(gcbf,seis)
end


%% This program is part of SplitLab
% ? 2006 Andreas W?stefeld, Universit? de Montpellier, France
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