function testCombineHeaders
% Script to test the reading and plotting of data

fprintf('\nReading Little Endian Files...\n');
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

fprintf('...read files.\nCombining header files...\n')

isPlot = true;
[hdr, seis1,  seis2, seis3] = combineHeaders(zhdr, zseis, ...
					     ehdr, eseis, ...
					     nhdr, nseis, isPlot );

disp(hdr)
end
