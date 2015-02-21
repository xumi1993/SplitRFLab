prefix='TA.O23A.big'  % prefix of for 3 components to open
zfile = [ prefix, '.BHZ' ];
efile = [ prefix, '.BHE' ];
nfile = [ prefix, '.BHN' ];
%function [SeisData, SAChdr,sacfiles]=sacsun2mat1(varargin)
% Read big endian sac files
%
% [SeisData, SAChdr,filenames] = SACSUNMAT('file1','file2',..., 'filen' )
%
% reads n SAC files file1, file2, filen (SAC files are assumed to have
% SUN byte order) and converts them to matlab
% format. The filenames can contain globbing characters (e.g. * and ?).
% These are expanded and all matching files loaded.
%
% SACSUNMAT( cellarray ) where cellarray={'file1','file2',...,'filen'}
% is equivalent to the standard form.
% 
%
% SAChdr is an n x 1 struct array containing the header variables
%         in the same format as is obtained by using MAT function
%         of SAC2000.
%         SAChdr(i).trcLen contains the number of samples.
%
% SeisData is an m x n array (where m=max(npts1, npts2, ...) )
%         containing the actual data.
%
% filenames is a n x 1 string cell array with the filenames actually read.
%
% Note that writing 
%
%  [SAChdr,SeisData] = sacsun2mat('file1','file2',..., 'filen' ) 
%
% is equivalent to the following sequence
% 
% sac2000
% READ file1 file2 .. filen
% MAT
%
% (in fact the failure of above sequence to work properly on my
% system motivated this script).
%
%
% SACSUN2MAT was written by F Tilmann (tilmann@esc.cam.ac.uk) 
% based on sac_sun2pc_mat  by C. D. Saragiotis (I copied the 
% routines doing the actual work from this code but
% used a different header structure and made the routine
% flexible). 
% It was tested on MATLAB5 on a PC but
% should work on newer versions, too.
%
% 
% IWB modified to accept entire path in the input file, only using one file
%
% (C) 2004
%


% Hardwire the output sample rate
% DTout = 0.025;

F = 4-1; % float byte-size minus 1;
K = 8-1; % alphanumeric byte-size minus 1
L = 4-1; % long integer byte-size minus 1;

fnames={};
for i=1:1
  if ischar(varargin)
    fnames=cell([fnames; cellstr(varargin)]);
  elseif iscellstr(varargin) && size(varargin,1)==1
    fnames=cell([fnames; varargin]);
  elseif iscellstr(varargin) && size(varargin,2)==1
    fnames=cell([fnames; varargin]);
  end
end
% expand globs
sacfiles={};k=1;
% for i=1:length(fnames)
%   dirlist=dir(fnames{i});
%   for j=1:length(dirlist)
%     if ~dirlist(j).isdir
%       sacfiles{k,1}=dirlist(j).name;
%       k=k+1;
%     end
%   end
% end
for i=1:length(fnames),
    filelist = strvcat( strread( ls(fnames{i}), '%s','delimiter','\n'));
    for j=1:size(filelist,1),
        if( exist( filelist(j,:), 'file') ),
            sacfiles{k,1}=filelist(j,:);
            k=k+1;
        end
    end
end
maxnpts=0;
for i=1:length(sacfiles)
  fid=fopen(sacfiles{i},'rb');
  if fid==-1
    error(sprintf('Could not open SAC file %s',fnames{i}))
  end
  SAChdr(i,1)=readSacHeader(fid,F,K,L);
  npts=SAChdr(i).trcLen;
  if npts>maxnpts
    maxnpts=npts;
  end
%  fprintf('Processing file %d: %s\n',i,sacfiles{i});
  SeisData(maxnpts,i)=0;   
%  SeisData(npts,i)=0;   
% Magnify seis matrix if necessary
  seisbuf=readSacData(fid,npts,F+1); 

 %  % Check sample rate. If necessary, resample
  
%   if SAChdr(i).times.delta ~= DTout;
%       ttempin = [0:SAChdr(i).times.delta:(length(seisbuf)-1)*SAChdr(i).times.delta];
%       ttempout = [0:DTout:max(ttempin)];
%       seisbuf = interp1(ttempin,seisbuf,ttempout,'cubic','extrap');
%   end
  
%   i1 = round(SAChdr(i).times.b/DTout) + 1;
%   i2 = i1 + length(seisbuf) - 1;
%   SeisData(i1:i2,i)= seisbuf;

SeisData(1:npts,i)= seisbuf;
%   SAChdr(i).times.b = 0;
  
fclose(fid);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
