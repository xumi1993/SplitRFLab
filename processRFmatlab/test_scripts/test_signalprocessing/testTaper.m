function testTaper
%
% Test Taper on example data

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
lims = plot3seis(te, eseis, tn, nseis, tz, zseis, ['E';'N';'Z']);

% combine components
fprintf('Combining...\n');
[hdr, t, eseis, nseis, zseis] = combineHeaders( ehdr, eseis,...
						nhdr, nseis,...
						zhdr, zseis );
seis = [eseis,nseis,zseis];

% Taper
taperw = 0.2;
fprintf('Tapering the start and end  %.1f percent...\n',[100*taperw])
[seis] = taperSeis( seis , taperw );

% plot again
hold on;
plot3seis(t, seis(:,1), t, seis(:,2), t, seis(:,3), ['E';'N';'Z'],...
	  0, 'x', '-r', lims);


return

