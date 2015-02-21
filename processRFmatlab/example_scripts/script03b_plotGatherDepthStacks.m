function script03b_plotGatherDepthStacks

% Use a 1-D velocity model to map receiver function amplitudes to depth
% Choose the moho from 1-d plots, then plot path in 3d

% directory containing all p receiver functions
pdir='./prfns/prfns_water_2.50/'; 

% suffix for files to stack
psuffix='PRF.sac'; 

dbaz = 5;
dp = 0.005;
dz = 1;
maxz = 100;
maxxy = 150;

%% get the file names 
[pfiles, ~] = getFilenames( pdir, psuffix );

%% use the AK135 continental model
[vmod.z, ~, vmod.vp, vmod.vs, ~, ~ ] = ak135( 'cont' );

%% Read in all files
[rflist, stIdx, nsta] = getSeisList( pfiles );

fprintf('Number of Rfns: %i\n', numel(rflist))
fprintf('Number of Stations: %i\n', nsta)

%% Loop through the stations
%for ista = 1:1,
for ista = 1:nsta,

  idx = find( stIdx==ista );
  nrf = length(idx);
  
  stnm = strtrim( rflist(idx(1)).station.kstnm );
  fprintf('\n%s:\n',stnm)
  fprintf('Number Rfns: %i\n',nrf)
  
  % plot the ray coverage at the start and get the slowness/back azimuth
  figure(1); clf;
  [rayp(idx), backaz(idx)] = plotSlowBaz( rflist(idx), stnm , 1, '.b'); hold on;

  % bin over back azimuth and slowness
  [time, pmid, bazmid, seiss, stds] = ...
      stack_pBaz( {rflist(idx).t}, {rflist(idx).seis}, rayp(idx), backaz(idx), ...
		  dp, dbaz, 'phase');

  nstk = numel(time);
  
  % convert stacked seismograms to depth
  [ depth, epos, npos, seis ] = mapPsSeis2depth_1d( time, seiss, ...
						    pmid, bazmid, ...
						    dz, vmod.z, vmod.vp, vmod.vs );

  % plot
  figure(2); clf;
  plotRFgather_rayp( depth, seis , pmid, bazmid, numel(seis) , 1, true)
  ax = axis();
  axis( [ ax(1), ax(2), ax(3), maxz ] );
  ylabel('Depth (km)')

  % get moho depths from user input
  disp('click on rfn moho depths')
  [rfi, mohoz] = ginput(nstk);

  % convert from x position to rf number
  rfi = round(rfi+0.5);
  
  % output results to terminal
  mohoxyz = zeros(nstk,3);
  for irf = 1:nstk,
    thisi = rfi(irf);
    mohox = interp1( depth{thisi}, epos{thisi}, mohoz(irf), 'linear' );
    mohoy = interp1( depth{thisi}, npos{thisi}, mohoz(irf), 'linear' );   
    fprintf( 'RFn %i moho coords (km): x = %.2f y=%.2f z=%.2f\n',...
	     [thisi,mohox,mohoy,mohoz(irf)] )
  
    mohoxyz(thisi,:) = [mohox, mohoy, mohoz(irf)]; 
  end

  % combine position data
  allpos = [ [epos{:}]', [npos{:}]', [depth{:}]' ];
  allv = [seis{:}]';
  
  % restrict depth and horizontal
  idx2 = find( allpos(:,3)<maxz & ( allpos(:,1).^2 + allpos(:,2).^2 )<maxxy^2 );
  allpos = allpos( idx2, : );
  allv = allv(idx2);
   
  % plot in 3d
  figure(4); clf;
  maxA = 0.5*max(max(abs(allv)));
  clims = [-maxA, maxA ];
  mycmap = repmat( [linspace(0,1,32), linspace(1,0,32)]', 1, 3 );
  mycmap(1:32,3) = ones(32,1);
  mycmap(33:64,1) = ones(32,1);
  colormap(  mycmap );
  scatter3( allpos(:,1), allpos(:,2), allpos(:,3), 20*ones(numel(allv),1 ), allv, ...
 	    'filled', 'LineWidth', 1 ); hold on;
  set(gca, 'CLim', clims );
  set(gca,'ZDir','reverse');
  xlabel( 'E-W distance (km)')
  ylabel( 'N-S distance (km)')
  zlabel( 'Depth (km)' );
  axis equal;

  % plot moho
  plot3( mohoxyz(:,1), mohoxyz(:,2), mohoxyz(:,3), 'xg' , 'LineWidth',2) 
  
  if( ista < nsta ),
    pause;
    close all;
  end

end




return
