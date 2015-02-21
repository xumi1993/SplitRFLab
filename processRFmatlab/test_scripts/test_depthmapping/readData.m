function [time, p, rfdata] = readData( DIR, filelist )
% read in the rfn data
%
% get the time, slowness and seismograms
%

nrfn = length(filelist); % number of receiver functions
[time,rfseis,hdr]=sac2mat( [DIR, filelist(1).name]);
npts = length(rfseis); % number of data points

% make container of rf data and slowness
rfdata = zeros(npts,nrfn);  
p = zeros(1,nrfn);

p(1) = hdr.user(1).data; % slowness is in user0
rfdata(:,1) = rfseis;
for k=2:nrfn,
  [time,rfseis,hdr] = sac2mat([DIR, filelist(k).name]);
  rfdata(:,k) = rfseis;
  p(k) = hdr.user(1).data;
end

return