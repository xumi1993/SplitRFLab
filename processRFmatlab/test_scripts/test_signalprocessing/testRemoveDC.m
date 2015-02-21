function testRemoveDC
%
% Test DC removal on example data

% read in the data
prefix='test_data/TA.Q20A'  % prefix of for 3 components to open

% Read  in the  components
fprintf('Reading...\n')
[te, eseis, ehdr] = sac2mat( [prefix, '.BHE'] );
[tn, nseis, nhdr] = sac2mat( [prefix, '.BHN'] );
[tz, zseis, zhdr] = sac2mat( [prefix, '.BHZ'] );

% combine components
fprintf('Combining...\n');
[hdr, t, eseis, nseis, zseis] = combineHeaders( ehdr, eseis,...
						nhdr, nseis,...
						zhdr, zseis );
% plot the components
seis = [eseis,nseis,zseis];
fprintf( 'Mean amplitudes : %d, %d, %d\n', sum(seis)/numel(t))

fprintf('Plotting...\n')
clf;
lims = plot3seis(t, seis(:,1), t, seis(:,2), t, seis(:,3), ['E';'N';'Z']);

% remove DC
fprintf('Removing DC...\n')
[seis] = removeSeisDC( seis );


% plot again
hold on;
plot3seis(t, seis(:,1), t, seis(:,2), t, seis(:,3), ['E';'N';'Z'],...
	  0, 'x', '--r', lims);

% Average components
fprintf( 'Mean amplitudes : %d, %d, %d\n', sum(seis)/numel(t))
return

