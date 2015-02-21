% Script to test the reading and plotting of data
function testReadBigEndian

fprintf('\nTesting Big Endian Files...\n');
prefix='2010.035.20.26.22.0175.zj.zj01_0.03_20.00'  % prefix of for 3 components to open
zfile = [ prefix, '.1sac' ];
efile = [ prefix, '.3sac' ];
nfile = [ prefix, '.2sac' ];

fprintf('\nTest that we catch the file format and report the error\n')
try [te, eseis, ehdr] = sac2mat( efile );
catch ME
  disp(ME.message)
end

fprintf('\nNow read in properly\n')
% Read each component
% East
try [eseis, ehdr] = sacsun2mat( efile );
catch ME
  disp(ME.message)
  error( 'Error reading E component file %s', efile )
end

% North
try [nseis, nhdr] = sacsun2mat( nfile );
catch ME
  disp(ME.message)
  error( 'Error reading N component file %s', nfile )
end

% Up
try [zseis, zhdr] = sacsun2mat( zfile );
catch ME
  disp(ME.message)
  error( 'Error reading Z component file %s', zfile )
end

% get the times
te = ehdr.times.b + ehdr.times.delta*(0:1:(numel(eseis)-1));
tn = nhdr.times.b + nhdr.times.delta*(0:1:(numel(nseis)-1));
tz = zhdr.times.b + zhdr.times.delta*(0:1:(numel(zseis)-1));

% plot
fprintf('\nTesting plot3seis function\n')
plot3seis( tz, zseis, tn, nseis, te, eseis, ['Z'; 'N'; 'E'] );

fprintf('Done... check plot\n');
