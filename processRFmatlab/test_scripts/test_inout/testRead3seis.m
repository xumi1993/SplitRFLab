% Script to test the reading 3 components simultaneously  and plotting of data
function testRead3seis

fprintf('\nReading Little Endian Files...\n');
prefix='test_data/TA.O23A.little'  % prefix of for 3 components to open

% get file names
zfile = [ prefix, '.BHZ' ];
efile = [ prefix, '.BHE' ];
nfile = [ prefix, '.BHN' ];

% Use function to read files in simultaneously
[eseis, nseis, zseis, hdr] = read3seis( efile, nfile, zfile );

% get the times
[t, dt, times, labels] = getTimes(hdr);
 
% plot 
 plot3seis( t, eseis, t, nseis, t, zseis, ['E'; 'N'; 'Z'], times, ...
	    labels );
 
 fprintf('Done\n')