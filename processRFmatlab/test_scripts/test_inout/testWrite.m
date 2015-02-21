function testWrite(ifile, ofile)
% Script to test the reading and writing of sac data

% set default file names
if( nargin < 2 ),
  ofile='TA.O23A.little.BHZ.v2'
  if( nargin < 1 ),
    ifile='TA.O23A.little.BHZ'
  end
end


% Read in the file
try
  [t,data,hdr] = sac2mat( ifile );
catch ME
  disp('****Problem Reading file****')
  disp(ME.message)
  return
end

% Write the file
writeSAC(ofile, hdr, data)
fprintf('Written to %s\n', ofile );