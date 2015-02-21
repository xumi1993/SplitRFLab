function [axH, axRC, axSC axSeis] = splitdiagnosticLayout(Synfig)



m1 = uimenu(Synfig,'Label',   'Quality');
q(1) = uimenu(m1,'Label',  'good ', 'Callback',@q_callback);
q(2) = uimenu(m1,'Label',  'fair ', 'Callback',@q_callback);
q(3) = uimenu(m1,'Label',  'poor ', 'Callback',@q_callback);
%  q(4) = uimenu(m1,'Label',  'trash', 'Callback',q_callback);
set(q,'Userdata',q)

m2 = uimenu(Synfig,'Label',   'IsNull');
n(1) = uimenu(m2,'Label',  'Yes',  'Callback',@n_callback);
n(2) = uimenu(m2,'Label',  'No ',  'Callback',@n_callback);
set(n,'Userdata',n)

m3 = uimenu(Synfig,'Label',   'Result');
n(1) = uimenu(m3,'Label',  'Save',      'Accelerator','s', 'Callback','saveresult;');
n(2) = uimenu(m3,'Label',  'Discard',   'Accelerator','d', 'Callback','close(gcbf)');
n(3) = uimenu(m3,'Label',  'Add remark','Accelerator','r', 'Callback', ...
    'n=thiseq.resultnumber; thiseq.tmpresult.remark = char(inputdlg(''Enter a remark to this result'', ''Remark'',1,{thiseq.tmpresult.remark})); clear n;');
set(n(1:2),'Userdata',n(1:2))

m4 = uimenu(Synfig,'Label',   'Figure');
uimenu(m4,'Label',  'Save current figure',  'Callback',@localSavePicture);
uimenu(m4,'Label',  'Page setup',           'Callback','pagesetupdlg(gcbf)');
uimenu(m4,'Label',  'Print preview',        'Callback','printpreview(gcbf)');
uimenu(m4,'Label',  'Print current figure', 'Callback','printdlg(gcbf)');

%% create Axes


% borders
fontsize = get(gcf,'DefaultAxesFontsize')-2;
uipanel('units','normalized',  'Position',[.025 .39  .96 .36],  'BackgroundColor', 'w', 'BorderType', 'line', 'HighlightColor','k');
uipanel('units','normalized',  'Position',[.025 .015 .96 .36],  'BackgroundColor', 'w', 'BorderType', 'line', 'HighlightColor','k');

%clf
axSeis     = axes('units','normalized', 'position',[.08 .78 .19 .2], 'Box','on', 'Fontsize',fontsize);
axSeis(2)  = axes('units','normalized', 'position',[.80 .8 .15 .16], 'Box','on', 'Fontsize',fontsize);

axRC(1) = axes('units','normalized', 'position',[.08 .42 .19  .28], 'Box','on', 'Fontsize',fontsize);
axRC(2) = axes('units','normalized', 'position',[.32 .42 .19  .28], 'Box','on', 'Fontsize',fontsize);
axRC(3) = axes('units','normalized', 'position',[.54 .43 .19  .27], 'Box','on', 'Fontsize',fontsize);
axRC(4) = axes('units','normalized', 'position',[.77 .42 .19  .28], 'Box','on', 'Fontsize',fontsize,'Layer','top');

axSC(1) = axes('units','normalized', 'position',[.08 .05 .19  .28], 'Box','on', 'Fontsize',fontsize);
axSC(2) = axes('units','normalized', 'position',[.32 .05 .19  .28], 'Box','on', 'Fontsize',fontsize);
axSC(3) = axes('units','normalized', 'position',[.54 .06 .19  .27], 'Box','on', 'Fontsize',fontsize);
axSC(4) = axes('units','normalized', 'position',[.77 .05 .19  .28], 'Box','on', 'Fontsize',fontsize,'Layer','top');



% header axes:
axH    = axes('units','normalized',  'Position',[.27 .8 .46 .14]);
axis off



%% SUBFUNTION menu


%% ---------------------------------
function q_callback(src,evt)
% quality menu callback
global thiseq
% 1) set menu markers
tmp1 = get(src,'Userdata');
set(tmp1(tmp1~=src),'Checked','off');
set(src,'Checked','on'),
thiseq.Q=get(src,'Label');


% 2) set figure header entries
tmp1 = findobj('Tag','FigureHeader');
tmp2 = get(tmp1,'String');
tmp3 = tmp2{end};
tmp3(29:33)=thiseq.Q;
tmp2(end) = {tmp3};
set(tmp1,'String',tmp2);

%% ---------------------------------
function n_callback(src,evt)
%null menu callback
global thiseq
% 1) set menu markers
tmp1 = get(src,'Userdata');
set(tmp1(tmp1~=gcbo),'Checked','off');
set(gcbo,'Checked','on')
thiseq.AnisoNull=get(gcbo,'Label');

% 2) set figure header entries
tmp1 = findobj('Tag','FigureHeader');
tmp2 = get(tmp1,'String');
tmp3 = tmp2{end};
tmp3(52:54) = thiseq.AnisoNull;
tmp2(end) = {tmp3};
set(tmp1,'String',tmp2);

%% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
function localSavePicture(hFig,evt)
global config thiseq
defaultname = sprintf('%s_%4.0f.%03.0f.%02.0f.result.',config.stnname,thiseq.date([1 7 4]));
defaultextension = strrep(config.exportformat,'.','');
exportfiguredlg(gcbf, [defaultname defaultextension])
