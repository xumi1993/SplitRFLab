function [phiRC, dtRC, Cmap, correctFastSlowRC,corrected_QT,  Eresult] =...
    splitRotCorr(Q, T, bazi, pickwin,maxtime, sampling)
% shear wave splitting using the Rotation-Correlation method
%  (e.g. Bowman and Ando,1987)
%
% INPUTS:
%    Q,T      = Sv and Sh seismogram components in Ray system as column vectors
%    bazi     = backazimuth
%    pickwin  = indices to pick
%    sampling = sampling of seismograms records (in seconds)
%
% OUTPUTS:
%    Cmatrix = correlation map of test directions
%    phiRC   = best estimated fast axis (RC-method)
%    dtRC    = best estimated delay time (RC-method)
%    correctFS_RC = vector of corrected components:
%                   first column:  Fast
%                   second column: Slow
% Andreas Wüstefeld 12.03.06


maxlags = ceil(maxtime/sampling); %only +-4 seconds relevant
zerolag = length(pickwin);
%searching for fast axis by rotating clock wise
% in L-Q-T system (right handed; L up, Q towards earthquake and T 
% perpendicular to both) about ray axis (L, == quasi veritcal, along P-path)
% in this local coordinate system the corresponding axis in are:
%
%                Q == x-axes           T ^
%                T == y-axis             |
%                L == uppointing         |     Q
%                                        +----->
%               
%starting at "9 o'clock" (=-90°); going to "12"; ending at "3" (=+90°)

phi_test = (-90:1:90)/180*pi;
phi_test = phi_test(1:end-1);
dt_test  = fix(0:2:4/sampling);      % test delay times (in samples)


M(1,1,:) =   cos(phi_test);      M(1,2,:) =  -sin(phi_test);
M(2,1,:) =   sin(phi_test);      M(2,2,:) =   cos(phi_test);


%% Rotate and correlate
%cross-covariance function (equal to mean-removed cross-correlation) of Q and T on test direction

Cmatrix = zeros(length(phi_test),2*maxlags+1);
E       = zeros(length(phi_test), length(dt_test));
for p=1:length(phi_test)
    %test slow-fast seismograms
    FS_Test = M(:,:,p) * [Q, T]';
    %cross-correlate Slow with Fast component:
    cor          = xcorr(FS_Test(1,pickwin), FS_Test(2, pickwin),'coeff' );%, 
    Cmatrix(p,:) = cor(zerolag-maxlags:zerolag+maxlags);   %correlation map
end

%% ATTENTION %%%%%%
%There is an (undocumented) inconsistency in Matlab between some UNIX/MAC and Windows machines!
%The XCORR function uses a different lag time! We have contacted Mathworks
%but they couldn't fix that phenomenon!
%try the following code on your machine:

%%%BEGIN CODE%%%
% z1 = [0 0 1 0 0];
% z2 = [0 1 0 0 0];
% C = xcorr(z1,z2, 'coeff');
% 
% [a,b] = max(C)
%%%END CODE%%% 

% if b = 6 then everything is fine
% some machines however give b=4; in thiscase please uncomment the
% following line:
%%%    Cmatrix = fliplr(Cmatrix);



 
[Cmax,idx]        = max((Cmatrix(:)));%abs
[phiidx,shiftidx] = ind2sub(size(Cmatrix), idx);
phimax            = phi_test(phiidx)/pi*180; % fast axis in Q-T system
phiRC             = phimax + bazi;           % fast axis in E-N system
shift             = shiftidx-maxlags-1;      % shift samples relative to zerolag





%% find if correlated or anti-correlated
Cmap = Cmatrix;
S = sign(Cmap(idx));%negative means Fast and slow are anti-correlated

if shift>=0
    % fast-axis arrives after slow-axis; substracting 90°  
    dtRC    = shift*sampling;
    phiRC   = mod(phiRC-90, 180);
    Cmap    = Cmap(:, (maxlags+1):2:end); %only use right side on map
    Cmap    = circshift(Cmap, round(bazi-90));
    theta   = (phimax-90)/180*pi;% angle between Q-axis and fast-axis

else %shift<0
    % fast-axis arrives before slow-axis; the standard
    phiRC   = mod(phiRC, 180);
    dtRC    = -shift*sampling;
    
    Cmap    = fliplr(Cmatrix(:, 1:2:(maxlags+1))); %only use left side on map
    Cmap    = circshift(Cmap, round(bazi));
    theta   = (phimax)/180*pi;     % angle between Q-axis and fast-axis

    shift   = -shift;
end


Cmap  = Cmap * -S;
shift = shift * S;
if S==-1
    theta =theta+pi/2;
end

if phiRC>90
    phiRC = phiRC-180; %put in -90:90
end
Eresult = min(Cmap(:));




%% output seismograms in fast/slow directions
M     = [cos(theta)  -sin(theta);
         sin(theta)   cos(theta)];
FS_Test  = M * [Q, T]' ;   % extended window
tmpFast  = FS_Test(1,pickwin);
tmpSlow  = FS_Test(2,pickwin+shift);


correctFastSlowRC(:,1)  = tmpFast; %fast component in pick window
correctFastSlowRC(:,2)  = tmpSlow; %slow component in shifted pick window


corrected_QT = M' * [ tmpFast; tmpSlow];
corrected_QT = corrected_QT';


