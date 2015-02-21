function gauss = gaussFilter( dt, nft, f0 )
%
% Compute a gaussian filter in the f-domain which is unit area in t-domain
%
% gauss = gaussFilter( dt, nft, f0 )
%
% IN:
% dt = sample interval
% nft = number freq points
% f0 = width of filter
% 
% OUT:
% gauss = filter
%
% filter has the form: exp( - (0.5*w./f0).^2 )
% the units of the filter are 1/s

df = 1.0/(nft*dt);
nft21 = 0.5*nft + 1;

% get frequencies
f = df*(0:1:nft21-1);

w = 2*pi*f;

% compute the gaussian filter
gauss = zeros(1,nft);
gauss(1:nft21) = exp( - 0.25*(w/f0).^2 )/dt;
%gauss(1:nft21) = exp( - pi*(f/f0).^2 )/dt;
gauss(nft21+1:end) = fliplr(gauss(2:nft21-1));

return