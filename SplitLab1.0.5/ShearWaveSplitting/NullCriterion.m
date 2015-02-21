function [good, fair, poor, goodN, fairN]=NullCriterion(phiSC, phiRC, dtSC, dtRC, varargin)
% automatically detect Nulls and quality of measurement

Omega = mod(abs(phiSC-phiRC),90);
dtSC(dtSC==0) = 1e-5;
Rdt   = dtRC./dtSC;

good = Omega<8  &  0.8<=Rdt & Rdt<=1.1;
fair = Omega<15 &  0.7<=Rdt & Rdt<=1.2 & ~good;
goodN = 37<=Omega & Omega<=53 & Rdt<=.2;
fairN = 32<=Omega & Omega<=58 & Rdt<=.3 & ~goodN;
poor= sum([good; fair; goodN; fairN])~=1;



% set all noisy transverse components to fair Nulls
if nargin==5
    SNR_T = varargin{1};
    noisy = SNR_T(:) < 3 & ~goodN(:);

    good(noisy)  = 0;
    fair(noisy)  = 0;
    poor(noisy)  = 0;

    fairN(noisy) = 1;
end


%changing from logical array to index
good  = find(good );
fair  = find(fair );
goodN = find(goodN);
fairN = find(fairN);
poor  = find(poor);



