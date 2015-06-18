function install_SplitLab
% installation of SplitLab
% -Adding SplitLab to the MATLAB search path
% -Installation of the matTaup-toolbox
%  for calculation of seismic travel times and paths
% -on Microsoft-Systems: assign icons
% -on non-Microsoft systems try to assign webbrowser (see docopt.m)
%
%
% In case of problems please check:
% - The file classpath.txt (containing the path to JAVA classes in Matlab)
%   should contain the propper path to the file "matTaup.jar" located by
%   default in $MATLABROOT/toolbox/matTaup/lib/mattaup.jar
%   You can view the file by typing in matlab: edit(which('classpath.txt'))
%   After editing classpath.txt you have to restart Matlab
%
% - The matlab search path should contain the following folders:
%      SplitlabX.X.X/
%      SplitlabX.X.X/Tools
%      SplitlabX.X.X/ShearWaveSplitting
%   The path to the SacLab Utility
%      SplitlabX.X.X/Saclab
%   The path pointing to matTaup (usually at the end of the path)
%      $MATLABROOT/toolbox/mattaup
%   For editing the path use the command:     pathtool   
%
%  Furthermore, Splitlab preferences are added to the Matlab environment
%  (See the prefdir documentation for further details on preferences). the
%  Splitlab Preferences contain the fields CONFIGURATION (default Splitlab 
%  project configuration), ASSOCIATIONS (figure export file types and, on
%  non-PCs, the system command line to open the file type) and  HISTORY 
%  (recently used Splitlab Projects). These preferences are only valid for 
%  the user, who installed SplitLab. However, if a new user run Splitlab,
%  new default preferences are automatically created for that user. In 
%  multiuser case be sure that all users have permission to the
%  Splitlab, Saclab and matTaup path and the paths are set correctly for
%  each user.
%
% have fun
% Andy W?tefeld
% September 2006



[pathstr,name,ext] = fileparts(mfilename('fullpath'));

%%
v = version;
if str2num(v(1:3))<7
    beep
    Answer = questdlg({'Error:', 'Matlab Version 7.0 or later is required for Splitlab. Sorry...',...
             'You appear to be using version ' version,....
              '',...
             'Full functionaliy will not be available',...
             '',...
             'Please make also sure that your Matlab installation contains the',...
             'Mapping Toolbox and the Signal Processing Toolbox',...
             ''},...
             'Version Error',...
             'Continue anyway', 'Cancel', 'Cancel');
    if strcmp(Answer, 'Cancel')
        return
    end
end
mapbox    = ~license('checkout','map_toolbox');
signalbox = ~license('checkout','signal_toolbox');

if any([mapbox signalbox])
        beep
        v=ver;
        toolboxes = upper(char({v.Name}));
    Answer = questdlg({'Error:', 'Mapping Toolbox and Signal Processing Toolbox ', 'are required for Splitlab. Sorry...',...
             'Full functionaliy will not be available',...
             '',...
              'Your current Matlab License contains the following toolboxes:',...
              toolboxes,...
             ''},...
             'License Error',...
             'Continue anyway', 'Cancel', 'Cancel');
    if strcmp(Answer, 'Cancel')
        return
    end
end


%%
%%
licensestring={'DISCLAIMER:',' '...
    '1) TERMS OF USE'...
    ['SplitLab is provided "as is" and without any warranty. The author cannot be held '...
    'responsible for anything that happens to you or your equipment. '],...
    'Use it at your own risk.',' ',...
    '2) LICENSE:',...
    ['SplitLab is free software; you can redistribute it and/or modify ',...
    'it under the terms of the GNU General Public License as published by ',...
    'the Free Software Foundation; either version 2 of the License, or ',...
    '(at your option) any later version.'],...
    ' ',...
    ['This program is distributed in the hope that it will be useful,',...
    'but WITHOUT ANY WARRANTY; without even the implied warranty of ',...
    'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the ',...
    'GNU General Public License for more details.'],...
    ' ',...
    ['You should have received a copy of the GNU General Public License ',...
    'along with this program; if not, write to the Free Software ',...
    'Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA'],' ',' '};

%% THE BEER-WARE LICENSE" (Revision 42):
% If we meet some day, and you think this stuff is worth it, you can buy me a beer in return
pos = get(0,'DefaultFigurePosition');
pos(3:4) = [ 560 420];
H = figure('Name', 'Splitlab Licence Agreement', 'Color','w','units','Pixel',...
    'NumberTitle','Off','ToolBar','none','MenuBar','none','Position',pos);
% movegui(H,'center')

ui    = uicontrol('style','text','Parent',H,'units','Pixel','String',licensestring,...
    'Position',[30 20 pos(3:4)-[60 130]], 'BackGroundColor','w','HorizontalAlignment','Center');
logo  = imread(fullfile(pathstr,'Doc','splitlabLogo.png'));
axpos = [pos(3)-190 pos(4)-120 158 110];
ax    = axes('units','Pixel','Position', axpos, 'parent',H);
image(logo)
axis off

ui = uicontrol('style','pushbutton','Parent',H,'units','Pixel','String','I agree...',...
    'Position',[190 15 90 25],'Callback',' set(0,''Userdata'',1);uiresume; closereq; ');
ui = uicontrol('style','pushbutton','Parent',H,'units','Pixel','String','I do not agree!!!',...
    'Position',[290 15 90 25],'Callback','set(0,''Userdata'',0);uiresume; closereq; ');
uiwait
agree = get(0,'Userdata');
if ~agree
    return
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    run(fullfile(pathstr,'Tools','postcardware.m'))
    run(fullfile(pathstr,'Tools','acknowledgement.m'))
    
    
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% installation starts here   
% remove earlier instalations of SplitLab from the path

P   = path;
sep = [0 findstr(pathsep,P)];
SL  = [0 findstr('SplitLab',P)]; %occurences of "SplitLab" in the path

for k=2:length(SL);
    ff  = find(SL(k-1)<=sep & sep<SL(k));
    s1 = sep(ff)+1;
    s2 = sep(ff+1);
    tmp = P(s1:s2);
    rmpath(tmp)
end



% check if matTaup is installed
javaClasspath = textread(which('classpath.txt'),'%s','delimiter','\n','whitespace','');% eqivalent to  javaclasspath('-static')
isMatTaup     = strfind(javaClasspath,'matTaup');

splitlabpath = pathstr;%[matlabroot filesep 'toolbox' filesep 'splitlab' filesep ];
matpath      = [matlabroot filesep 'toolbox' filesep 'matTaup' filesep ];
saclabpath   = [pathstr filesep 'Saclab' filesep ];
toolboxpath  = [matlabroot filesep 'toolbox' filesep];

installSplitlab = 1;
installSaclab   = 1;
if all (cellfun('isempty',isMatTaup))
   installMatTaup  = 1;
else
    installMatTaup=0;
end

next=0;
installSL_GUI
waitfor(h)
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%% INSTALL starts here
if ~next%user did not press the "next" button
    return
end


if all([installSplitlab, ~(exist(splitlabpath,'dir')==7)])
    mkdir(splitlabpath)
    splitlabpath
end
if all([installSaclab, ~(exist(saclabpath,'dir')==7)])
    mkdir(saclabpath)
end
if installSaclab
    oldSACpath = [pathstr filesep 'Saclab' filesep ];
    if ~strcmp(oldSACpath, saclabpath)
        movefile([oldSACpath  '*'], saclabpath)
    end
end

matpath = strrep(matpath, [filesep 'matTaup'], '');%will be added from the .zip file


if all([installMatTaup, ~(exist(matpath,'dir')==7)])
    linenumber = find (cellfun('isempty',isMatTaup));
    mkdir(matpath)
    disp(matpath)
end


processRFmatlab_root='../processRFmatlab';


% Check the directory exists
if ~exist(processRFmatlab_root, 'dir'),
    error('You need to edit this script to point to your directory')
    return;
end

% Now add the paths for all the functions individually
fprintf('Adding deconvolution functions to path\n');
addpath(fullfile(processRFmatlab_root,'deconvolution'));

fprintf('Adding depthmapping functions to path\n');
addpath(fullfile(processRFmatlab_root,'depthmapping'));

fprintf('Adding getinfo functions to path\n');
addpath(fullfile(processRFmatlab_root,'getinfo'));

fprintf('Adding inout functions to path\n');
addpath(fullfile(processRFmatlab_root,'inout'));

fprintf('Adding plotting functions to path\n');
addpath(fullfile(processRFmatlab_root,'plotting'));

fprintf('Adding signalprocessing functions to path\n');
addpath(fullfile(processRFmatlab_root,'signalprocessing'));

fprintf('Adding velocity models to path\n');
addpath(fullfile(processRFmatlab_root,'velmodels1D'));

fprintf('Adding some useful tiny codes to path\n');
addpath(fullfile(processRFmatlab_root,'Tinycodes'));

savepath;

disp(' ')
disp('*******************************************')
disp('adding directories to Matlab Path')
if installSaclab
    addpath(saclabpath)
    disp(saclabpath)
end
if installSplitlab
    addpath([splitlabpath filesep 'ShearWaveSplitting'])
    addpath([splitlabpath filesep 'Tools'])
    addpath(splitlabpath)
    
    
    disp([splitlabpath filesep 'ShearWaveSplitting'])
    disp([splitlabpath filesep 'Tools'])
    disp(splitlabpath)
end



%% matTauP
if installMatTaup
    disp(' ')
    disp('*******************************************')
    disp('extracting matTaup.zip and add to MATLAB path')
    disp([matpath 'matTaup' filesep])
    unzip(fullfile([pathstr filesep 'Tools'],'matTaup.zip'),matpath)
    pause(1)%necessary to for system processes to end; don't know why...
    disp('*******************************************')
    disp(' ')
    matpath = [matpath 'matTaup' filesep];
    addpath(matpath, '-end');
    savepath

    disp('Updating static java classpath')
    disp('*******************************************')
    clpath=which('classpath.txt');
    disp(clpath)
    if ~(matpath(end)==filesep)
        matpath=[matpath filesep];
    end
    jfile = [matpath 'lib' filesep 'matTaup.jar'];
    fid   = fopen(clpath,'a+');
    if fid==-1
        commandwindow
        error('SplitLab:Install',['Opening of classpath.txt failed.\n',...
            ' You need Root/Administrator privileges to change this file. \n',...
            ' Please contact your system administrator to add following line to \n',...
            ' ', strrep(clpath,'\','\\'), ':\n',...
            strrep(jfile,'\','\\') ])
    else
        fseek  (fid, 0, 'eof'); %go to end of file
        fprintf(fid,'%s\n',jfile);
        fclose(fid);
        disp('*******************************************')
    end
end

%% Registering SAC-files and Splitlab-projects (Windows only)
if ispc
    disp(' ')
    disp(' ')
    disp('Registering SplitLab-Project Files: ')
    dos('assoc .pjt=SplitLabProject');
    dos('assoc .sac=SACfile');
    [xxx,xxx] = dos(['ftype SACfile=']);
    dos(['ftype SplitLabProject=' matlabroot '\bin\win32\matlab.exe -minimize -memmgr fast -r openpjt(''"%1"'');"global thiseq";splitlab']);
    disp(' ')
    disp(' ')
    disp('registering SAC- and PJT-icons:')
    disp('SplitlabProject')
    dos(['reg add HKCR\SplitLabProject\DefaultIcon /ve /f /d "' pathstr '\Tools\project.ico"']);
    disp(' ')
    disp(' ')
    disp('SAC')
    dos(['reg add HKCR\SACfile\DefaultIcon /ve /f /d "' pathstr '\Tools\sacfile.ico"']);
    %     disp('registering file types:')
    [xxx,xxx] = dos(['reg add HKCR\SplitLabProject /ve /f /t REG_SZ /d "SplitLab Project"']);
    [xxx,xxx] = dos(['reg add HKCR\SACfile /ve /f /t REG_SZ /d "SAC seismogram"']);
end

%% preferences
    disp(' ')
    disp(' ')
disp('Generating Splitlab Default Preferences')

config=SL_defaultconfig;
SL_preferences(config);

disp('*******************************************')
pause(2)



%% DOCOPT
% on non-Windows machine
if ~ispc & ~strncmp(computer,'MAC',3)
    [doccmd,options,docpath] = docopt
    if isempty(doccmd)
        try
            edit('docopt.m')
        catch
            docsearch docopt
            error(['For full functionality of Splitlab, the external WEB-browser needs to\n',...
                ' be specified on Unix-systems. You need root privileges to edit \n ',...
                strrep(which('docopt.m'),'\','\\') '\n',...
                ' Please contact your Administrator \n\n See also   ',...
                sprintf('<a href="matlab:help docopt">docopt</a>') ],'\n')
        end
        pause(1)
    else
        docsearch docopt
        beep
        disp('For full functionality of Splitlab, the external WEB-browser needs to')
        disp(['be specified on Unix-systems. Current Browser is ' doccmd])
        disp('If this is correct you can continue, otherwise please ')
        disp('edit <a href="matlab:docopt.m">docopt.m</a>')
    end
    
    commandwindow
    disp(' ')
    disp('You may want to add the following lines to your .bashrc file:')
    disp(' ')
    disp('###############################################################')
    disp('#SPLITLAB')
    disp('alias splitlab=''unset LANG; cd; matlab -nodesktop -r splitlab''')
    disp('###############################################################')
    disp(' ')
    pause(2)
end




%% FINISHING
button = questdlg({'SplitLab installed', 'To changes take effect, please restart MATLAB!', ' Have fun'}, ...
    'Exit Dialog','Restart Matlab','Later','Restart Matlab');
switch button
    case 'Restart Matlab';
        if ispc
            !matlab /nosplash /r splitlab&
        else
            eval(['!cd ' matlabroot filesep 'bin'])
            eval(['!matlab -nosplash -r splitlab&'])  
        end
        quit
    case 'Later',
end



