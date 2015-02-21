% Script to test the reading and plotting of data
function testGetFilenames

dir='./test_data/';
suffix='BHZ';

fprintf('\nSearching for files with suffix %s',	suffix)
fprintf(' in the directory %s\n',dir)

files= getFilenames( dir, suffix );

fprintf('\n%i files\n', numel(files) )

for i = 1:numel(files),
  fprintf('File %i: ', i)
  fprintf('%s\n', files{i} )
end

fprintf('Done\n')
end