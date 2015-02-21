function setSplitOptions
%set the option for calculation the best split estimate

global config
 
  S   = get(0,'PointerLocation');
 pos = [S(1)-50 S(2)-290 270  330];

 figure( 'NumberTitle','off',...
        'name','Options',...
        'MenuBar','None',...
        'Position', pos,...
        'WindowStyle','modal');

h  = uipanel('visible','off','Position',[0.01 0.01 .98 .98]);
hb = uibuttongroup('visible','off','Position',[0.03 0.25 .94 .4], 'parent',h,'Title','Method');
hi = uibuttongroup('visible','off','Position',[0.03 0.01 .94 .2], 'parent',h,'Title','Polarisation for EV method');

uicontrol('Style','Text','String','Please send any wishes to',...
    'position',[10 pos(4)-25 250 15],'parent',h,'HandleVisibility','off',...
    'foregroundColor','k','HorizontalAlignment', 'center');
uicontrol('Style','Pushbutton','String','Splitlab@gmx.net',...
    'position',[75 pos(4)-50 120 20],'parent',h,'HandleVisibility','off',...
    'foregroundColor','b','callback',@santaclaus,...
    'HorizontalAlignment', 'center');
%%%%%%
uicontrol('Style','popupMenu','String','1|2|3|4|5|6|7|8',...
    'pos',[175 pos(4)-75 60 20],'HandleVisibility','off',...
    'Value',config.maxSplitTime,...
    'BackgroundColor','w',...
    'Callback','config.maxSplitTime=get(gcbo,''Value'');');
uicontrol('Style','text','String','Maximum Split time [sec]',...
    'pos',[10 pos(4)-80 140 20])
%%%%%%
str = {'raw','100','50','20','10'};
val = strmatch(config.resamplingfreq, str);
uicontrol('Style','popupMenu','String',str,...
    'pos',[175 pos(4)-105 60 20],'HandleVisibility','off',...
    'Value',val,...
    'BackgroundColor','w',...
    'Callback','tmp=get(gcbo,''string''); config.resamplingfreq = tmp{get(gcbo,''Value'')};SL_SeismoViewer(thiseq.index)');
uicontrol('Style','text','String','Resample Seismogram to [Hz]',...
    'pos',[10 pos(4)-110 150 20])




% a = axes('Units','Pixel','Parent',h,'position',[150 95 120 20]);
% text(0,0,'Splitlab@gmx.net','Color','b','VerticalAlignment','Baseline',...
%     'FontSize',get(0,'DefaultUicontrolFontSize'),'HorizontalAlignment','Center')
% axis off


uicontrol('Style','Text','String','Please select a spliting method:',...
    'pos',[10 75 200 20],'parent',hb,'HandleVisibility','off',...
    'fontweight','bold','HorizontalAlignment', 'left');

u3 = uicontrol('Style','Radio','String','Eigenvalue: max(lambda1)',...
    'pos',[10 10 200 20],'parent',hb,'HandleVisibility','off',...
    'Tag','MaxL1');
u4 = uicontrol('Style','Radio','String','Eigenvalue: min(lambda1 * lambda2)',...
    'pos',[10 30 200 20],'parent',hb,'HandleVisibility','off',...
    'Tag','MinL1L2');
u0 = uicontrol('Style','Radio','String','Eigenvalue: min(lambda2)',...
    'pos',[10 50 200 20],'parent',hb,'HandleVisibility','off',...
    'Tag','MinL2');
u1 = uicontrol('Style','Radio','String','Eigenvalue: max(lambda1 / lambda2)',...
    'pos',[10 70 200 20],'parent',hb,'HandleVisibility','off',...
    'Tag','MaxL1L2');
u2 = uicontrol('Style','Radio','String','Minimum Energy',...
    'pos',[10 90 200 20],'parent',hb,'HandleVisibility','off',...
    'Tag','MinE');




i1 = uicontrol('Style','Radio','String','fixed (=backazimuth)',...
    'pos',[10 25 200 20],'parent',hi,'HandleVisibility','off','Tag','fixed');
i2 = uicontrol('Style','Radio','String','estimated (from wave form)',...
    'pos',[10 5 200 20],'parent',hi,'HandleVisibility','off','Tag','estimated');




set(hi,'SelectionChangeFcn',@selopt);
set(hb,'SelectionChangeFcn',@selcbk);
set(hb,'SelectedObject',[]);  % No selection
set([h,hb,hi],'Visible','on');

switch config.splitoption
    case 'Minimum Energy'
        set(u2,'Value',1)
    case 'Eigenvalue: max(lambda1 / lambda2)'
        set(u1,'Value',1)
    case 'Eigenvalue: min(lambda2)'
        set(u0,'Value',1)
    case 'Eigenvalue: max(lambda1)'
        set(u3,'Value',1)    
    case 'Eigenvalue: min(lambda1 * lambda2)'
        set(u4,'Value',1)
    otherwise
        errordlg('Unknown Option! Defaulting to Minimum Energy on Transverse')
         set(u0,'Value',1)
         config.splitoption = 'Minimum Energy';
end

switch config.inipoloption
    case 'fixed'
        set(i1,'Value',1)
    case 'estimated'
        set(i2,'Value',1)
    otherwise
        errordlg('Unknown Option! Defaulting to fixed initial polarisation')
         set(i1,'Value',1)
         config.inipoloption = 'fixed';
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selcbk(source,eventdata)
global config

config.splitoption = get(eventdata.NewValue,'String');
close(gcbf)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selopt(source,eventdata)
global config

config.inipoloption = get(eventdata.NewValue,'Tag');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function santaclaus(src,evt)
global config

bodyText = strcat('Dear Santa Claus%0A%0A',...
    'My name is%20', upper(config.request.user), '%20and I am working on station%20', ...
    config.stnname,'%20(Lat=', num2str(config.slat), ',Long=', num2str(config.slong), ') .%0A',...
    'I like SplitLab very much, but could please make that...');
web(['mailto:"splitlab@gmx.net?subject=Dear Santa Claus&body=' bodyText '"'],'-helpbrowser')