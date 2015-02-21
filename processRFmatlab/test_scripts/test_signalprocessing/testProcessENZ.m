function testProcessENZ
%
% Test processing of three component data

% read in the data
prefix='test_data/TA.Q20A'  % prefix of for 3 components to open

% set the processing arguments
opt.MINZ = 10; % min eqk depth
opt.MAXZ = 600; % max eqk depth
opt.DELMIN = 30; % min eqk distance
opt.DELMAX = 95; % max eqk distance
opt.PHASENM = 'P'; % phase to aim for
opt.TBEFORE = 20.0; % time before to cut
opt.TAFTER = 100.0; % time after p to cut
opt.TAPERW = 0.05; % proportion of seis to taper
opt.FLP = 1.5; % low pass
opt.FHP = 0.02; % high pass
opt.FORDER = 4; % order of filter
opt.DTOUT = 0.1; % desired sample interval
opt.MAGMIN = 5.5; % min magnitude to include
opt.MAGMAX = 6.0; 

disp('Options:')
disp(opt)

% Read  in the  components
fprintf('Reading...\n')
[eseis, nseis, zseis, hdr] = read3seis( [prefix, '.BHE'], ...
					[prefix, '.BHN'], ...
					[prefix, '.BHZ'] );

% get times 
[t, dt, times, labels] = getTimes( hdr );

% plot the components
fprintf('Plotting...\n')
clf;
lims = plot3seis(t, eseis, t, nseis, t, zseis, ['E';'N';'Z'], times, ...
		 labels);

% check depth units
hdr.event.evdp = checkDepthUnits( hdr.event.evdp, 'km');

% check conditions
if( checkConditions(hdr, opt) ),
  processENZseis( eseis, nseis, zseis, hdr, opt, true, true );
else
  fprintf('Didnt pass tests\n');
end

disp('...Done')

