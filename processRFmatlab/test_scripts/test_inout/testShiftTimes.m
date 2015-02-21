% Script to test the reading and plotting of data
function testShiftTimes

fprintf('\nTesting Little Endian Files...\n');
prefix='test_data/TA.O23A.little'  % prefix of for 3 components to open

% get file names
zfile = [ prefix, '.BHZ' ];
efile = [ prefix, '.BHE' ];
nfile = [ prefix, '.BHN' ];

% Read each file in 
try [te, eseis, ehdr] = sac2mat( efile );
catch ME
  disp(ME.message)
  error( 'Error reading E component file %s', efile )
end
try 
  [tn, nseis, nhdr] = sac2mat( nfile );
catch ME
  disp(ME.message)
  error( 'Error reading N component file %s', nfile )
end
try 
  [tz, zseis, zhdr] = sac2mat( zfile );
catch ME
  disp(ME.message)
  error( 'Error reading Z component file %s', zfile )
end

% Get the arrival times
fprintf('\nTesting getTimes.m from z component...\n');
[t, dt, times, labels] = getTimes( zhdr );

% plot results
fprintf('\nTesting plot3seis function\n')
plot3seis( tz, zseis, tn, nseis, te, eseis, ['Z'; 'N'; 'E'] ,...
	   times, labels);

%
tmp = input('Check the plot and press any key...')

tshift = 20;
fprintf('\nShifting times  %f s\n', tshift)

% shift header times
hdr = shiftSacHdrTimes( zhdr, tshift );

% get the times again
[t, dt, times, labels] = getTimes( hdr );
plot3seis( tz, zseis, tn, nseis, te, eseis, ['Z'; 'N'; 'E'] ,...
	   times, labels);



fprintf('Done\n');
