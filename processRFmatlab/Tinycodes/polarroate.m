function [P,SV] = polarroate(R,Z,W,extime_before,dt)
%% Rotate to P-SV-SH
Alpha = 5;
startime = extime_before / dt;

for t=1:length(R)
winbegin  = t - floor( W/2 / dt);
winfinish = t + floor( W/2 / dt);
if winbegin <= 0 
    winbegin = 1;
elseif winfinish >= length(R)
    winfinish =length(R);
end
winIndex  = winbegin:winfinish;

%   winT =  T(winIndex);
    winR =  R(winIndex);
    winZ =  Z(winIndex);

% Caculate the covariance matrix
V = cov(winR,winZ);
% calculating the eigenvalues and the eigenvectors
[Ve,d]=eig(V);
e1=Ve(:,1);e2=Ve(:,2); %e1=[eZ1,eR1]T;e2=[eZ2,eR2]T
d1=d(1,1);d2=d(2:2);
if e1(1)/e1(2) > tan(Alpha) || e1(1)/e1(2) < -1/tan(Alpha)
    OP = [1;0];
    OS = [0;1];
elseif e1(1)/e1(2) < tan(Alpha) && e1(1)/e1(2) < -1/tan(Alpha)
    OP = [0;1];
    OS = [1;0];
end
P(t) =  [Z(t) R(t)]*Ve*OP;
SV(t) = [Z(t) R(t)]*Ve*OS;
end