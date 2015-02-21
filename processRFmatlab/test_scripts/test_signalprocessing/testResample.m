function testResample
%
% Test resampling on example data

% read in the data
prefix='test_data/TA.Q20A'  % prefix of for 3 components to open

% Read  in the  components
fprintf('Reading...\n')
[te, eseis, ehdr] = sac2mat( [prefix, '.BHE'] );
[tn, nseis, nhdr] = sac2mat( [prefix, '.BHN'] );
[tz, zseis, zhdr] = sac2mat( [prefix, '.BHZ'] );

% plot the components
fprintf('Plotting...\n')
clf;
lims = plot3seis(te, eseis, tn, nseis, tz, zseis, struct( 'clabs', ['E';'N';'Z'] ));

% combine components
fprintf('Combining...\n');
[hdr, t, eseis, nseis, zseis] = combineHeaders( ehdr, eseis,...
						nhdr, nseis,...
						zhdr, zseis );
seis = [eseis,nseis,zseis];

% resample
dtin = hdr.times.delta;
dtout = 0.1;
fprintf('Resampling from %f to %f...\n',[dtin,dtout])
[seis, dt, t] = resampleSeis( seis , t, dtout );

% update the header info
hdr.times.b = t(1);
hdr.times.e = t(end);
hdr.times.delta = dt;
hdr.trcLen = numel( t);

% plot again
hold on;
plot3seis(t, seis(:,1), t, seis(:,2), t, seis(:,3), ...
	  struct( 'clabs', ['E';'N';'Z'],...
		  'ltype', '--r', 'lims', lims ) );


return

