function testChop
%
% Test seismogram chopping on example data

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

% chop the seismogram
t0 = t(1)+10;
t1 = t(end)-10;

fprintf('Chopping between %f and %f...\n',[t0,t1])
[seis,t] = chopSeis( seis, t, t0, t1 );

% update the header 
hdr.times.b = t(1);
hdr.times.e = t(end);
hdr.trcLen = numel(t);

% plot again
hold on;
plot3seis(t, seis(:,1), t, seis(:,2), t, seis(:,3), ['E';'N';'Z'],...
	  0, 'x', '--r', lims);


return

