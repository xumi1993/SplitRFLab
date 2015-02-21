function testCheckCond
%
% Test resampling on example data


% read in the data
prefix='test_data/TA.Q20A'  % prefix of for 3 components to open

% set the conditions
opt.MINZ = 10;
opt.MAXZ = 600;
opt.DELMIN = 30;
opt.DELMAX = 95;
opt.MAGMIN = 5.5;
opt.MAGMAX = 8.5;

disp('Options:')
disp(opt)

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
% put depth in km
hdr.event.evdp = hdr.event.evdp/1e3;

% display values
fprintf('Event depth: %.2f km\n', hdr.event.evdp)
fprintf('Event-Station distance: %.2f ^o\n', hdr.evsta.gcarc)

fprintf('Passes test? %i\n', checkConditions(hdr,opt))

% change depth   
depth0 = hdr.event.evdp;

for depth = [0.0, 650],
  hdr.event.evdp = depth;
  fprintf('Event depth: %.2f km\n', hdr.event.evdp)
  fprintf('Passes test? %i\n', checkConditions(hdr,opt))
end

hdr.event.evdp = depth0;

% change Del
del0 = hdr.evsta.gcarc;
for del = [29.0, 100],
  hdr.evsta.gcarc = del;
  fprintf('Event-Station distance: %.2f ^o\n', hdr.evsta.gcarc)
  fprintf('Passes test? %i\n', checkConditions(hdr,opt))
end

disp('...Done')

return

