function script03a_plotGatherTimeStacks

% make plots of the receiver functions for each station
% bin in slowness and back azimuth

pdir='/Users/xumj/Documents/MATLAB/processRFmatlab/example_scripts/prfns/prfns_water_2.50/'; % directory containing all p receiver functions
suffix='*PRF.sac'; % suffix for files to stack
isRad = true; % true = the slowness in the header is in s/rad

dbaz = 90; % azimuth bin width ( degrees )
dp = 0.005; % slowness bin width (s/km)
mint=0; maxt=40; % min and max times to plot

% get the file names 
[files, ~] = getFilenames( pdir, suffix );

% Read in all files
[rflist, stIdx, nsta] = getSeisList( files );

fprintf('Number of Rfns: %i\n', numel(rflist))
fprintf('Number of Stations: %i\n', nsta)

% Loop through the stations
%for ista = 1:1,
for ista = 1:nsta,

  idx = find( stIdx==ista );
  nrf = length(idx);
  
  stnm = strtrim( rflist(idx(1)).station.kstnm );
  fprintf('\n%s:\n',stnm)
  fprintf('Number Rfns: %i\n',nrf)
  
  % plot the ray coverage at the start
  figure(1); clf;
  [rayp, backaz] = plotSlowBaz( rflist(idx), stnm, isRad ,'.k');

  % get the stacks
  [time, pmid, bazmid, seiss, ~] = ...
      stack_pBaz( {rflist(idx).t}, {rflist(idx).seis}, rayp, backaz, ...
		  dp, dbaz, 'phase');

  % get the unique back azimuths
  b_uniq = sort(unique( mod(bazmid, 180) ));
  nplots= numel(b_uniq); % loop through the first half
  
  % get the region to plot
  allp = min(pmid):dp:max(pmid);
  allt = sort( unique( [time{:}] ) );
  allt = allt( allt>mint & allt <=maxt );
  
  % get a grid
  [ time, seiss ] = cellarrs2commongrid( time, seiss, allt );

  % loop through the back aximuths
  for iplot = 1:nplots,
    figure(iplot+1); clf
    
    % get the stacks with correct back azimuth
    bidx = find( bazmid==b_uniq(iplot) );

    if( numel(bidx) > 0 ),
      % plot on right hand side
      subplot(1,2,2);
      plotSeisGrid( allp, allt, pmid(bidx), time, seiss(:,bidx) );
      set(gca,'YTickLabel',[]);
      p = get(gca, 'pos');
      set( gca, 'pos', [0.55, 0.05, 0.4, p(4)] );
      set( gca, 'XMinorTick', 'on' );
      title(sprintf('az_B = %.1f',b_uniq(iplot)))
    end
    
    % get stacks with 180 degree difference
    bidx = find( bazmid==b_uniq(iplot)+180 );
    if( numel(bidx) > 0 ),

      % plot on the left hand side
      subplot(1,2,1);
      plotSeisGrid( allp, allt, pmid(bidx), time, seiss(:,bidx) );
      set(gca,'XDir','reverse');
      ylabel('Time (s)')
      p = get(gca, 'pos');
      set( gca, 'pos', [0.1, 0.05, 0.4, p(4)] );
      set( gca, 'XMinorTick', 'on' );
      title(sprintf('az_B = %.1f',b_uniq(iplot)+180))
    end
  
  end
  
  if(ista<nsta),
	pause;
	close all;
 end
end




return
