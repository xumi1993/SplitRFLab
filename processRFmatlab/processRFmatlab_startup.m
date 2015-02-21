%PROCESSRFMATLAB_STARTUP is a simple script to put the functions into
% your path.  You need to manually set the root directory to wherever
% you saved the codes.  If you want to have access to the functions
% every time you start matlab, put the code in this script into your
% startup.m file which is in your userpath (type userpath to find out
% where that is).

%-- processRFmatlab_startup.m ---
%
%  Filename: processRFmatlab_startup.m
%  Description: Get the functions into your matlab path
%  Author: Iain W. Bailey
%  Created: Mon Jun 18 20:58:29 2012 (-0400)
%  Version: 1
%  Last-Updated: Tue Jun 19 21:21:45 2012 (-0400)
%            By: Iain W. Bailey
%      Update #: 31
%
%-- Change Log:
%
%

% The following two lines will work if you put these codes
% directly into your matlab userpath.
%tmp_userpath = char(userpath);
% processRFmatlab_root = fullfile( tmp_userpath(1:end-1), ...
%                                 'processRFmatlab');
%
% Otherwise you can hard code it. For example, comment out the above
% two lines and add
% >> processRFmatlab_root='/path/to/processRFmatlab';
% on linux, or for windows
% >> processRFmatlab_root='C:\directory\where/you\saved\processRFmatlab'
%
% In my case...
processRFmatlab_root=pwd;


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

% Clean up variables
clear processRFmatlab_root;

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
%-- Code:



%-- processRFmatlab_startup.m ends here
