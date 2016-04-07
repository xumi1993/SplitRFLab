function [doccmd,options,docpath] = docopt
%DOCOPT Web browser defaults.
%	DOCOPT is an M-file that you or your system manager can
%	edit to indicate how to access the program and files that 
%	allow viewing of the MATLAB online documentation.
%
%	[DOCCMD,OPTIONS,DOCPATH] = DOCOPT returns three strings DOCCMD,
%	OPTIONS, and DOCPATH.
%	DOCCMD is a string containing the command that DOC uses
%	to view the MATLAB online documentation. Its default is:
%
%	   Unix:      netscape
%	   Windows:   -na-
%	   Macintosh: -na-
%	   VMS:       -na-
%
%	OPTIONS is a string containing additional configuration options
%	that are to accompany the invocation of DOCCMD when the DOC
%	command is called. Its default is:
%
%	   Unix:      ''
%	   Windows:   -na-
%	   Macintosh: -na-
%	   VMS:	      -na-
%
%	DOCPATH is a string containing the path to the MATLAB online
%	documentation files. If DOCPATH is empty, the DOC command
%	automatically computes the path to the files.
%
%       Configuration on Unix:
%       ---------------------
%       1. For global defaults edit and replace this file, i.e.
%              $MATLAB/toolbox/local/docopt.m
%       2. For personal preferences which override the values set
%          in 1. copy this file, i.e.
%              $MATLAB/toolbox/local/docopt.m
%          to
%              $HOME/matlab/docopt.m
%          and make your changes there.  In MATLAB, the Unix commands
%          to make the directory and do the copy are:
%
%               !mkdir $HOME/matlab
%               !cp $MATLAB/toolbox/local/docopt.m $HOME/matlab
%
%          For the changes to take effect in the current MATLAB
%          session, be sure that $HOME/matlab is on your MATLABPATH.
%          This will be the case if this directory existed prior to
%          starting up MATLAB.  If it does not exist on your path in
%          the current session type:
%
%               addpath([getenv('HOME') '/matlab'])
%
%          to add it to the beginning of your MATLABPATH.
%
%	See also DOC.

% $Revision: 1.15 $  $Date: 1998/01/05 23:19:56 $

% Intialize options to empty matrices
doccmd = []; options = []; docpath = [];

% This file automatically defaults to the options and doccmd shown above
% in the online help text. If you would like to set the options or doccmd
% default to be different from those shown above, enter it after this
% paragraph.

%---> Start of your own changes to the defaults here (if needed)
%
cname = computer;

if isunix                       % UNIX
%   doccmd = '';
%   options = '';
%   docpath = '';
elseif strcmp(cname(1:2),'PC')  % PC
%   doccmd = '';
%   options = '';
%   docpath = '';
elseif strcmp(cname(1:2),'MA') % MAC
%   doccmd = '';
%   options = '';
%   docpath = '';
elseif isvms                   % VMS			
%   doccmd = '';
%   options = '';
%   docpath = '';
else                           % other
%   doccmd = '';
%   options = '';
%   docpath = '';
end
%---> End of your own changes to the defaults here (if needed)

% VMS_webhelp is a global that controls the help message displayed
% when calling web functions. Set to one help is displayed once. Set
% to 0 help is not displayed. Set to another number, help is always
% displayed.
if isvms 
    global VMS_webhelp;
    if isempty(VMS_webhelp)
      VMS_webhelp=1;
    end;
end;

% ----------- Do not modify anything below this line ---------------
% The code below this line automatically computes the defaults 
% promised in the table above unless they have been overridden.

cname = computer;

if isempty(doccmd)

	% For Unix
	if isunix, doccmd = 'netscape'; end

	% For Windows
	if strcmp(cname(1:2),'PC'),  doccmd = ''; end

	% For Macintosh
	if length (cname) >= 3 
	    if strcmp(cname(1:3),'MAC'), doccmd = ''; end
	end

        % For OpenVMS
        if isvms, doccmd = 'netscape'; end
end

if isempty(options)

	% For Unix
	options = '';

	% For Windows
	if strcmp(cname(1:2),'PC'),  options = ''; end

	% For Macintosh
	if length (cname) >= 3 
	    if strcmp(cname(1:3),'MAC'), options = ''; end
	end

	% For OpenVMS
	if isvms, options = ''; end
end

if isempty(docpath)
	docpath = '';
end
