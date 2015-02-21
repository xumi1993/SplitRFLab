function files = getThreeCompFilenames( thisdir, suff1, suff2, suff3 )
%GETTHREECOMPFILENAMES finds matching file names for three components of a
%  seismogram
%
% files = getThreeCompFilenames( thisdir, suff1, suff2, suff3 )
%
% IN (required):
% thisdir = the name of the directory to search (search includes sub-directories) 
% suff1, suff2, suff3 = suffixes for each of the components
%
% OUT:
% files = list of files
%
% EXAMPLE:
% files = getThreeCompFilenames( pwd, '.BHE', '.BHN', 'BHZ' )
%
% NOTES:
% - The filename and path before the different suffixes should be identical 

% Written IW Bailey 2010
% Changes
%   June 2010, updated to work on Windows
%thisdir=fullfile('example_data','seismograms');suff1='3.sac';suff2='2.sac';suff3='3.sac';
% start with the first suffix
[fnames1, nf1] = getFilenames( thisdir, suff1 );
if( nf1 == 0 ),
    error('No files with suffix %s', suff1)
end
 
[fnames2, nf2] = getFilenames( thisdir, suff2 );
if( nf2 == 0 ),
    error('No files with suffix %s', suff2)
end

[fnames3, nf3] = getFilenames( thisdir, suff3 );
if( nf3 == 0 ),
    error('No files with suffix %s', suff3)
end

% print a warning if varying number of files
if( nf1 ~= nf2 || nf1 ~= nf3 || nf2 ~= nf3 ),
  fprintf('Warning: Mismatch in number of files for each component\n')
  fprintf('\tNumber of *%s/%s/%s files: %i/%i/%i\n', ...
      suff1, suff2, suff3, nf1, nf2, nf3);
  fprintf('This function will only use the prefixes for *%s files\n\n', ...
      suff1 );
end


% loop through all files
for i1 = nf1:-1:1,
  
  % get the prefix for the first file
  [fullpath, fname1, ext] = fileparts(fnames1{i1});
  
  % Find the indices of the correposnding files
  i2 = find( ~cellfun('isempty', strfind( fnames2, fullfile(fullpath,fname1) )));
  i3 = find( ~cellfun('isempty', strfind( fnames3, fullfile(fullpath,fname1) )));
  
  % Check if we have three results
  if( numel(i2) ~= 1 ),
      fprintf('Couldn''t find a %s match for %s.ext\n',suff2,fname1,ext);
  elseif( numel(i3) ~= 1 ),
      fprintf('Couldn''t find a %s match for %s.ext\n',suff3,fname1,ext);
  else
      files(i1).name1 = fnames1{i1};
      files(i1).name2 = fnames2{i2};
      files(i1).name3 = fnames3{i3};
      disp(files(i1))
  end

end

% Remove any we couldn't find
files = files( ~cellfun('isempty',{files.name1}) );

return