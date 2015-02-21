function [fnames, nf] = getFilenames( startdir, pattern)
%startdir=fullfile('example_data','seismograms');pattern='BHE';
%GETFILENAMES performs a recursive search for filenames 
%
% [fnames, nf] = getFilenames( startdir, pattern)
%
% Perform a recursive search of the specified directory for any file names
% containing the specified string
%
% IN:
% startdir = (string) directory to search
% pattern = (string) pattern to look for in all files 
%
% OUT:
% fnames = (cell array) list of filenames such that fnames{1} gives the first one
% nf = number of filenames
%
% EXAMPLE
% To get a list of all matlab functions/scripts/classes below current dir
%  [fnames, nf] = getFilenames(pwd,'.m')


% Written IW Bailey 2009.
% Modified June 2012 to work on Windows

nf = 0;
fnames = {};

% Get a list of all sub directories below startdir
pathstr = genpath(startdir);
subdirs = textscan( pathstr, '%s','delimiter',';');
subdirs = subdirs{1};

% Loop through all subdirectories
for i=1:numel(subdirs),
    
    % Get list of non-directory contents
    d = dir(subdirs{i});
    d = d(~[d.isdir]);
    
    % Search for the pattern in the remaining string
    isMatch = ~cellfun('isempty',strfind({d.name},pattern));

    % Add the matching file names to the output array
    for idx = find(isMatch),
        nf = nf+1;
        fnames{nf} = fullfile(subdirs{i}, d(idx).name);
    end
end


%
% % use the unix command to find the files
% [a, fnames]=unix(['find ', DIR, ' -name \*', pattern]);
% 
% % split based on new line
% fnames = strread(fnames, '%s', 'delimiter', sprintf('\n'));
% 
% % get the number
% nf = size(fnames,1);

end
