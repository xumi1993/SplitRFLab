function seisfigbuttons(fig,seismo)
%create buttons for seismogram plot SL_SeismoViewer and assings callbacks
global thiseq

if nargin<1
    fig =gcf;
end
ht = uitoolbar(fig);

load('icon.mat');
%%
uipushtool(ht,'CData',icon.sac,...
    'TooltipString','Export current seismograms to SAC format',...
    'ClickedCallback', {@exportsac,seismo});
% uipushtool(ht,'CData',icon.save,...
%     'TooltipString',['Save project as  "' config.project '"'] ,...
%     'ClickedCallback', 'suivant');
% hpt(12) = uipushtool(ht,'CData',icon.axt,...
%     'TooltipString','Split event',...
%     'ClickedCallback','Aniso_Pre(filt)');
uipushtool(ht,'CData',icon.open,...
    'TooltipString','Select earthquake from table' ,...
    'ClickedCallback', 'SL_databaseViewer');
uipushtool(ht,'CData',icon.print,...
    'TooltipString','Print...',...
    'ClickedCallback','printdlg(gcbf)' );

uitoggletool(ht,'CData',icon.grid,...
    'TooltipString','toggle grid',...
    'onCallback','grid on',...
    'offCallback','grid off');


uipushtool(ht,'CData',icon.map,...
    'TooltipString','Show travel times',...
    'BusyAction','Cancel',...
    'ClickedCallback','viewphases');
uitoggletool(ht,'CData',icon.xzoomIN,...
    'TooltipString','x-ZOOM in',...
    'onCallback',{@xzoomON,seismo},...
    'offCallback',{@xzoomOFF,seismo},...
    'Tag','xzoom');
uipushtool(ht,'CData',icon.xzoomOUT,...
    'TooltipString','x-ZOOM out',...
    'ClickedCallback',{@xzoomOutON, seismo});



uipushtool(ht,'CData',icon.back,...
    'separator','on',...
    'TooltipString','previous earthquake',...
    'ClickedCallback','idx = thiseq.index-1; if idx < 1; idx = length(eq);end; SL_SeismoViewer(idx); clear idx',...
    'BusyAction','Cancel' );

PFig = findobj('Type','Figure','Name','Particle motion');
if isempty(PFig)
    state='off';  
else
    ax = get(PFig,'Children'); 
    delete(get(ax,'Children'))
    state='on';
end
uitoggletool(ht,'CData',icon.particle,...
    'TooltipString','Show particle motion of selection Window',...
    'State',state,...
    'Tag','ParticleButton',...
    'onCallback',{@SL_localparticlemotion,seismo},...
    'offCallback','close(findobj(''Type'',''Figure'', ''Name'',''Particle motion'')); ');
uipushtool(ht,'CData',icon.home,...
    'TooltipString','Zoom to selected phase',...
    'ClickedCallback',@goHome);
if strcmp(thiseq.system,'ENV')
    s  = 'off';
    im = icon.geo;
    imm = icon.ENZ;
else
    s  = 'on';
    im = icon.ray;
    imm = icon.RTZ;
end
uitoggletool(ht,'CData',icon.ray,...
    'UserData',      icon, 'State', s,...
    'TooltipString','show East-North-Vertical or L-T-Q system (3D rotated in ray direction) seismogramms',...
    'onCallback',   {@changesystem,seismo,'ray'},...
    'offCallback',  {@changesystem,seismo,'geo'},...
    'Cdata',im,...
    'Tag','SystemButton');


uitoggletool(ht,'CData',icon.ENZ,...
    'UserData',      icon, 'State', s,...
    'TooltipString','show East-North-Vertical or R-T-Z system (horizontally rotated in azi direction) seismogramms',...
    'onCallback',   {@changesystem,seismo,'RTZ'},...
    'offCallback',  {@changesystem,seismo,'ENZ'},...
    'Cdata',imm,...
    'Tag','RTZButton');
uitoggletool(ht,'CData',icon.unlocked,...
    'UserData',      icon, 'State', 'off',...
    'TooltipString','Lock or unlock Y-axis linking',...
    'Tag', 'LockButton',...
    'onCallback',   @changelockstate,...
    'offCallback',  @changelockstate);
uipushtool(ht,'CData',icon.next,...
    'TooltipString','next earthquake',...
    'ClickedCallback','idx = thiseq.index+1; if idx > length(eq); idx =1;button = MFquestdlg([ 0.4 , 0.42 ],''Do you want to quit the database?'',''PS_RecFunc'',''Yes'',''No'',''Yes'');if strcmp(button, ''Yes'');close(figure(2));close(figure(3));close(figure(4));clear idx; else SL_SeismoViewer(idx); clear idx;end;else SL_SeismoViewer(idx);clear idx; end',...
    'BusyAction','Cancel');


uipushtool(ht,'CData',icon.spect,...
     'TooltipString','show spectogram of selection',...
     'Separator','on',...
     'ClickedCallback','seisspectrum');


uipushtool(ht,'CData',icon.config,...
    'TooltipString','Set Splitting options',...
    'ClickedCallback','setSplitOptions',...
'BusyAction','Cancel');


%% %USER DEFINED function
%enter the name of your function; mus be a string
PSFunction =  strcat('PS_RecFunc');
SPFunction =  strcat('SP_RecFunc');
Plot_testINC_SP =  strcat('Plot_testINC_SP');
%create yuor own symbol: assume an indexed GIF image user.gif is located at c:\
%it has to bee at max 20x20 pixel!
%uiopen('F:\ahzjanisotropy\PS_logo.gif',1)
% %this will gif you the indexmap cdata and a colormap
%User = ind2rgb(cdata, colormap); %create RGB image
%Logic = cdata==35; %we are assuming that the transparent color of the image has the index number 35
%Logic = repmat(Logic,[1,1,3]); %for each colorlayer (Red, Green, Blue)
%User(Logic)=nan; % image entries with NaNs are 'displayed' transparent
% %now load the icon.mat variable in /Splitlab/privat/icon.mat
%icon.user=User;
%save Splitlab/privat/icon.mat icon

uipushtool(ht,'CData',icon.user,...
    'TooltipString','PS receiver function',...
    'ClickedCallback', 'if config.issac; PS_RF_sac;else;PS_RF;end;');

uipushtool(ht,'CData',icon.user1,...
    'TooltipString','SP receiver function',...
    'ClickedCallback', SPFunction);

uipushtool(ht,'CData',icon.user2,...
    'TooltipString','Plot INC tests for SP RF',...
    'ClickedCallback', Plot_testINC_SP);

%%


uipushtool(ht,'CData',icon.trash,...
    'TooltipString','delete',...
    'Separator','on',...
    'ClickedCallback',{@localTrash,seismo});
 uipushtool(ht,'CData',icon.sound,...
     'TooltipString','Play selection',...
     'ClickedCallback',@playseismo);
uipushtool(ht,'CData',icon.camera,...
    'TooltipString','save grafic ...',...
    'ClickedCallback',@localSavePicture);
tmp = mfilename('fullpath');
tmp = fileparts(tmp);
tmp = strrep(tmp, 'private', ['Doc' filesep 'Keyboard_shortcuts.html']);

cbstr = ['web (''' tmp  ''')' ];
uipushtool(ht,'CData',icon.help,...
    'TooltipString','Help',...
    'ClickedCallback',cbstr);






%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% S U B F U N C T I O N S                                            %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
function goHome(src,evt)
global thiseq  
%jump close to selected phase
    val  = get(findobj('Tag','PhaseSelector'),'Value');
    t_home = floor(thiseq.phase.ttimes(val)/10)*10 - 30; %~30 seconds before phase; at full 10 seconds
    xlim([t_home t_home+150]) % timewindow of 150 sec
    
%%    
function changelockstate(src,event)
seis  = findobj('Tag','seismo');

switch get(src,'State')
    case 'on'%lock to common Y-limits
        for k=1:3
            yyy(k,:)   =get(get(seis(k),'Parent'),'YLim');
        end
        yyy =[min(yyy(:,1)) max(yyy(:,2))];
        for k=1:3
            set(get(seis(k),'Parent'), 'YLim',yyy,'YLimMode','manual')
        end
        set(src,'Cdata',getfield(get(src,'UserData'),'locked'))
    case 'off'%unlock Y-limits
        for k=1:3
            set(get(seis(k),'Parent'),'YLimMode','auto')
        end
        set(src,'Cdata',getfield(get(src,'UserData'),'unlocked'))
end
%% ------------------------------------------------------------------
function playseismo(a,b)
global thiseq

if ~isfield(thiseq, 'a')
    errordlg('Please select a time window first...')
    return
end

o  = thiseq.Amp.time(1);
ia = floor((thiseq.a-o)/thiseq.dt);
ib = ceil((thiseq.f-o)/thiseq.dt);


seis   = findobj('tag','seismo');
y(:,1) = get(seis(1),'Ydata');
y(:,2) = get(seis(2),'Ydata');

y = y(ia:ib,:); %only selection
y = y/max(y(:))*1000;%we normalize and amplify the seismogram, to listen 
                     %to the same loudness for each seismogram

sound(y, 1000)%shift it in audible frequencies

%% ------------------------------------------------------------------
function exportsac(src,event,seis)
global thiseq config
persistent exportdir %make it the same for subsequent calls during this matlab session

if isempty(exportdir)
    exportdir = config.savedir;
end
exportdir = uigetdir(exportdir);
if ~exportdir %cancelled
    return
end


%% ----------------------------
Amp(1,:) = get(seis(1), 'Ydata');
Amp(2,:) = get(seis(2), 'Ydata');
Amp(3,:) = get(seis(3), 'Ydata');
time     = get(seis(1), 'Xdata');

%only export current zoom
xx     = xlim;
window = find(xx(1) <=time & time<=xx(2));
Amp    = Amp(:,window); 
time   = time(window);


if thiseq.system=='ENV'
    cname ='ENZ';
elseif thiseq.system=='LTQ'
    cname ='LTQ';
end
if ~isfield(thiseq,'a')
    A = -12345;
    F = -12345;
else
    A = thiseq.a;
    F = thiseq.f;
end

%determine date and hour of file begin
starttime = datenum(thiseq.date(1), thiseq.date(2), thiseq.date(3), thiseq.date(4), thiseq.date(5), thiseq.date(6)+time(1));
D         = datevec(starttime);
JJJ       = dayofyear(D(1), D(2), D(3));

files=[];
for m=1:3
    %access structure using dynamic filed names
    tmp  = bsac(time,Amp(m,:));
    tmp = ch(tmp,...
        'DELTA',  mean(diff(time)),...
        'O',      0,...
        'B',      time(1),...
        'E',      time(end),...
        'A',      A,...
        'F',      F,...
        'NPTS',   length(time),...
        'KSTNM',  config.stnname,...
        'KNETWK', config.netw,...
        'STLA',   config.slat,...
        'STLO',   config.slong,...
        'KCMPNM', cname(m),...
        'EVLA',   thiseq.lat,...
        'EVLO',   thiseq.long,...
        'EVDP',   thiseq.depth,...
        'BAZ',    thiseq.bazi,...
        'GCARC',  thiseq.dis,...
        'IZTYPE', 11,...      %'IO'; reference time is hypo time
        'NZYEAR', thiseq.date(1),...
        'NZJDAY', thiseq.date(7),...
        'NZHOUR', thiseq.date(4),...
        'NZMIN',  thiseq.date(5),...
        'NZSEC',  floor(thiseq.date(6)),...
        'NZMSEC', round((thiseq.date(6) - floor(thiseq.date(6)))*1000));
    num = min([9   length(thiseq.phase.ttimes)-1]);%SAC allows only 10 picks
    for k=0:num
        tmp = ch(tmp,...
            ['T' num2str(k)] , thiseq.phase.ttimes(k+1),...
            ['KT' num2str(k)], char(thiseq.phase.Names(k+1)));
    end
    fname = sprintf('%04.0f.%03.0f.%02.0f.%02.0f.%07.4f.%s.%s_%0.2f_%0.2f_%c.SAC',...
        D(1), JJJ, D(4), D(5), D(6),...
        config.netw, config.stnname, thiseq.filter,cname(m));
    outname = fullfile(exportdir,fname);
    files   = strvcat(files,fname);
    wsac(outname, tmp)
end
helpdlg({'SAC files written to directory',exportdir, ' ', files})


%% ------------------------------------------------------------------
function changesystem(src,event,seis,sys)
global thiseq
%change icon of button
switch sys
    case 'geo'
        set(src,'CData', getfield(get(src,'UserData'),'geo'));
        thiseq.system='ENV';
    case 'ray'
        set(src,'CData', getfield(get(src,'UserData'),'ray'));
        thiseq.system='LTQ';
    case 'RTZ'
        set(src,'CData', getfield(get(src,'UserData'),'RTZ'));
        thiseq.system='RTZ';
    case 'ENZ'
        set(src,'CData', getfield(get(src,'UserData'),'ENZ'));
        thiseq.system='ENV';
end
%plot new data:
SL_updatefiltered(seis)

%% -----------------------------------
function SL_localparticlemotion(src,evt,seis)
SL_showparticlemotion(gcbf,seis)


%% ---------------------------------
function localSavePicture(hFig,evt)
global config thiseq
defaultname = sprintf('%s_%4.0f.%03.0f.%02.0f.preview.',config.stnname,thiseq.date([1 7 4]));
defaultextension = strrep(config.exportformat,'.','');
exportfiguredlg(gcbf, [defaultname defaultextension])

%% ---------------------------------
function localTrash(hFig,evt,seis)
global config thiseq eq


button = questdlg({'The current earthquake will be removed', 'from this project database.', 'Are you sure?'}, ...
    'Remove earthquake','Yes','Cancel','Yes');
switch button
    case 'Yes';
        fname = fullfile(config.savedir,['trashfiles_' config.stnname '.log' ]);
        fid   = fopen(char(fname),'a+');
        fprintf(fid,'%s\n%s\n%s\n',thiseq.seisfiles{1}, thiseq.seisfiles{2}, thiseq.seisfiles{3});
        fclose(fid);
        
        if ispc
            try
                pathstr = fileparts(mfilename('fullpath'));
                [y,Fs,bits] = wavread(fullfile(pathstr, 'Papierkorb.wav'));
                audioplayer(y*2,Fs,'async' )
            end
        end

        idx = thiseq.index;
        L   = [1:idx-1 idx+1:length(eq)];        
        eq  = eq(L);
        SL_SeismoViewer(idx)
        
        databaseViewer = findobj('Type','Figure', 'Name','Database Viewer');
        if ~isempty(databaseViewer)
           SL_databaseViewer
        end
        
    case 'Later'
end




%%
function xzoomON(src,evt,seismo)
ud.down=get(gcbf,'WindowButtonDownFcn');
ud.up  =get(gcbf,'WindowButtonUpFcn');
ud.motion=get(gcbf,'WindowButtonMotionFcn');
set(src,'Userdata',ud);
s=nan;
pointer=[
    s s s s 1 1 1 1 s s s s s s s s
    s s 1 1 s 2 s 2 1 1 s s s s s s
    s 1 2 s 2 s 2 s 2 s 1 s s s s s
    s 1 s 2 s 1 1 2 s 2 1 s s s s s
    1 s 2 s 2 1 1 s 2 s 2 1 s s s s
    1 2 s 1 1 1 1 1 1 2 s 1 s s s s
    1 s 2 1 1 1 1 1 1 s 2 1 s s s s
    1 2 s 2 s 1 1 2 s 2 s 1 s s s s
    s 1 2 s 2 1 1 s 2 s 1 s s s s s
    s 1 s 2 s 2 s 2 s 2 1 s s s s s
    s s 1 1 2 s 2 s 1 1 1 1 s s s s
    s s s s 1 1 1 1 s s 1 1 1 s s s
    s s s s s s s s s s s 1 1 1 s s
    s 1 s s s s s 1 s s s s 1 1 1 s
    1 1 1 1 1 1 1 1 1 s s s s 1 1 1
    s 1 s s s s s 1 s s s s s s 1 s];
set(gcbf,...
    'WindowButtonDownFcn',{@localZoomSeismo,gcbf,seismo},...
    'WindowButtonUpFcn','',...
    'WindowButtonMotionFcn','',...
    'Pointer','Custom','PointerShapeCData',pointer,'PointerShapeHotSpot',[7 7])

function xzoomOFF(hFig,evt,seismo)
ud=get(gcbo,'Userdata');
set(gcbf,...
    'WindowButtonDownFcn',ud.down,...
    'WindowButtonUpFcn',ud.up,...
    'WindowButtonMotionFcn',ud.motion,...
    'Pointer','crosshair')
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xzoomOutON(src,evt,seismo)
t   = get(seismo(2),'xData');
x   = xlim;
xx  = diff(x/2);
xxx = x+[-xx xx];
if xxx(1) < t(1);   xxx(1) = t(1);   end
if xxx(2) > t(end); xxx(2) = t(end); end

subax=findobj('Type','Axes','Parent',gcbf);
set(subax(4),'xlim', round(xxx))





function localZoomSeismo(hFig,evt,fig,seismo)
% k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1);              % extract x and y
point2 = point2(1);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
x = [p1(1) p1(1)+offset(1) ];

if x(2)-x(1) < 2
    %prevent exessive zooming smaller than 2seconds
    return
end

subax=findobj('Type','Axes','Parent',gcbf);
set(subax(4),'xlim', round(x(1:2)))

