function testShift
%
% Test shift on example data

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

% shift
tshift = 20.0;
fprintf('Circular shifting  %.1f s...\n',[tshift])
[t0, seis1] = shiftSeis( seis , t(1), hdr.times.delta, tshift, true );

% plot again
hold on;
plot3seis(t, seis1(:,1), t, seis1(:,2), t, seis1(:,3), ['E';'N';'Z'],...
	  0, 'x', '-r', lims);

fprintf('Chopping shifting  %.1f s...\n',[tshift])
[t0, seis2] = shiftSeis( seis , t(1), hdr.times.delta, tshift, false );
nt = length(seis2(:,1));
t = t(1) + hdr.times.delta*(0:(nt-1));

% plot again
hold on;
plot3seis(t, seis2(:,1), t, seis2(:,2), t, seis2(:,3), ['E';'N';'Z'],...
	  0, 'x', '--b', lims);

% shift backwards
tshift = -20;
figure;
clf;
lims = plot3seis(te, eseis, tn, nseis, tz, zseis, ['E';'N';'Z']);
hold on;


fprintf('Chopping shifting  %.1f s...\n',[tshift])
[t0, seis2] = shiftSeis( seis , t(1), hdr.times.delta, tshift, false );
nt = length(seis2(:,1));
t = t(1) + hdr.times.delta*(0:(nt-1));

% plot again
hold on;
plot3seis(t, seis2(:,1), t, seis2(:,2), t, seis2(:,3), ['E';'N';'Z'],...
	  0, 'x', '-b', lims);


return

