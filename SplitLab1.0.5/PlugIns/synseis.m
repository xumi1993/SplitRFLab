function [t, ur, ut] = synseis(t, t0, sigma, phi, dt)
%create synthetic seismogramm form time derivative of gaussian function
%midpoint at t0

sample = mean(diff(t));
s = round(dt/sample); %shift in samples

w  = -2* (t-t0)/sigma.* exp(-((t-t0)/sigma).^2);

e=length(w);
w1 =  w(s+1:e)';%t+dt/2
w2 =  w(1:e-s)';%t-dt/2

ur =   w1*cos(phi/180*pi)^2 + w2*sin(phi/180*pi)^2 ;
ut = 0.5 * [w1 - w2]*sin(2*phi/180*pi) ;
 


t=t(1:end-s)';
% figure(10)
%  subplot(2,1,1)
%   plot(t,ur,'b-', t,ut,'k-');
%   xlim([290 310])
%  subplot(2,1,2)
%   plot(t,w1,'r', t,w2,'b')
%   xlim([290 310])
%  plot(ur,ut)
%  axis equal
