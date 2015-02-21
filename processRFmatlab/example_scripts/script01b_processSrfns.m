function script01b_processSrfns(isPlot)
% script01b_processSrfns(isPlot)
%
% Script that processes all Srfns for the example data
%
% isPlot = true to plot and pause after each processing step, false for auto

%-- processAllSrfns.m ---
%
%  Filename: processAllSrfns.m
%  Description: Example processing P receiver functions
%  Author: Iain W. Bailey
%  Maintainer: Iain W. Bailey
%  Created: Mon Jun 18 21:48:58 2012 (-0400)
%  Version: 1
%  Last-Updated: Mon Jun 18 21:51:52 2012 (-0400)
%            By: Iain W. Bailey
%      Update #: 8
%
%-- Change Log:
% Checked it works on June 18th 2012
%
%-- Code:

if( nargin < 1 ),
    isPlot = true; % plot during rfn computing
end
isVb = true; % verbose output

%% Set parameters for processing.
opt.MINZ = 1; % min eqk depth
opt.MAXZ = 600; % max eqk depth
opt.DELMIN = 55; % min eqk distance
opt.DELMAX = 95; % max eqk distance
opt.PHASENM = 'S'; % phase to aim for
opt.TBEFORE = 120.0; % time before to cut
opt.TAFTER = 120.0; % time after p to cut
opt.TAPERW = 0.05; % proportion of seis to taper
opt.FLP = 1.0; % low pass
opt.FHP = 0.02; % high pass
opt.FORDER = 3; % order of filter
opt.DTOUT = 0.1; % desired sample interval
opt.MAGMIN = 5.5 % minimum magnitude to include
opt.MAGMAX = 8.0 % minimum magnitude to include

rfOpt.T0 = -60; % time limits for receiver function
rfOpt.T1 = 15;
rfOpt.F0 = 1.0; % gaussian width for filtering rfns
rfOpt.WLEVEL = 1e-2; % water level for rfn processing
rfOpt.ITERMAX = 200; %  max number of iterations in deconvolution
rfOpt.MINDERR = 1e-5; % min allowed change in RF fit for deconvolution

% make a taper for removing some of the signal
phaseerr = 2; % number of seconds phase pick may be wrong
taperlen = round(5.0/opt.DTOUT);
taper=hann(2*taperlen);
taper = taper(1:0.5*numel(taper));

% set the directory containing all event data in sub directories
basedir=fullfile('example_data','seismograms');

% base directory for output
odir = fullfile('srfns');
if( ~exist( odir , 'dir') ), mkdir( odir ); end

%% Get the filenames for each event station pair three component files
enzfiles = getThreeCompFilenames( basedir , 'BHE', 'BHN', 'BHZ');

% number of files
nf = length(enzfiles);
fprintf('Number of station-receiver pairs: %i\n', nf );

%% Loop through each set of 3 components
for i =1:nf,
%for i =1:1,

  % get the prefix of the file name
  fprintf('\n%s\n',enzfiles(i).name3)

  %% Read the data
  try
    [eseis, nseis, zseis, hdr] = read3seis(enzfiles(i).name1, ...
					   enzfiles(i).name2, ...
					   enzfiles(i).name3 );
  catch ME
    disp(ME.message);
    continue;
  end

  %% Check arrival is there

  % get arrival times 
  [~, ~, atimes, labels] = getTimes( hdr );

  if( isnan( getArrTime( opt.PHASENM, atimes, labels ) ) ),
      fprintf('Time of %s arrival not found in header. \n...Skipping\n', ...
          opt.PHASENM);
      % Skip to next
      continue;
  end

  %% check depth units
  hdr.event.evdp = checkDepthUnits( hdr.event.evdp, 'km');

  %% Check event conditions
  if( checkConditions(hdr, opt) ),
    % process and rotate
    [zseis, rseis, tseis, hdr] = processENZseis( eseis, nseis, zseis, ...
						 hdr, opt, isVb, isPlot );
  else
    fprintf('Didnt pass depth/distance/magnitude tests\n');
    continue;
  end

  % get rid of denominator signal before the S arrival
  [t, dt, times, labels] = getTimes( hdr );
  ts = getArrTime( opt.PHASENM, times, labels );
  ntpre = numel( t(t<=(ts-phaseerr)) );
  rseis(1:ntpre-taperlen) = 0.0;
  rseis(ntpre-taperlen+1:ntpre) = taper.*rseis(ntpre-taperlen+1:ntpre);

  %% Make the water level rfn, z over r
  if( isVb ), fprintf('Making Rfn water level...\n'); end
  [rftime, rfseis, rfhdr] = processRFwater(zseis, rseis, hdr, ...
					 rfOpt , false);

  %% Plot and output receiver functions
  if( isPlot ),
    clf;
    p1 = plot( rftime, rfseis, '-b', 'linewidth', 2 ); hold on;
  end

  % make the output file
  rfodir = fullfile( odir, sprintf('srfns_water_%0.2f',rfOpt.F0) );
  ofname = getOfname( rfodir, rfhdr );

  % write
  writeSAC( ofname, rfhdr, rfseis );
  fprintf('Written to %s\n',ofname)

  %% Make the iterative rfn
  if( isVb ), fprintf('Making Rfn iterative...\n'); end
  [rftime, rfseis, rfhdr] = processRFiter(zseis, rseis, hdr, rfOpt , false);
  
  rfodir = fullfile( odir, sprintf('srfns_iter_%0.2f',rfOpt.F0) );
  ofname = getOfname( rfodir, rfhdr );

  % write
  writeSAC( ofname, rfhdr, rfseis );
  fprintf('Written to %s\n',ofname)

  % plot
  if( isPlot ),
    p2 = plot( rftime, rfseis, '-r', 'linewidth', 2 );
    axis tight; xlabel('Time (s)'); ylabel('Amplitude (/s)');
    legend([p1,p2], 'water level', 'iterative')

    [~] = input('Press a key to continue');
  end
end

%--------------------------------------------------
function ofname = getOfname( rfodir, rfhdr )
% make the output directories and get the output file name
%

% check the output directory exists
if( ~exist( rfodir , 'dir') ),
    mkdir(rfodir); 
end

% make the station specific directory
staDIR = sprintf('%s_%s/',strtrim(rfhdr.station.knetwk),strtrim(rfhdr.station.kstnm) );
staDIR = fullfile(rfodir,staDIR);
if( ~exist( staDIR , 'dir') ),
    mkdir( staDIR ); end

% make the station/event specific rfn
filename = sprintf('%04i_%03i_%02i%02i_%s_%s.SRF.sac', rfhdr.event.nzyear, ...
		   rfhdr.event.nzjday, rfhdr.event.nzhour, rfhdr.event.nzmin, ...
		   strtrim(rfhdr.station.knetwk), ...
		   strtrim(rfhdr.station.kstnm) );

ofname = fullfile( staDIR, filename );

% combine
return

%-- processAllSrfns.m ends here
