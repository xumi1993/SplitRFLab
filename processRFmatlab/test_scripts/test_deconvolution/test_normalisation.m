function test_normalisation(isprompt)
% test the deconvolution codes to see if the filter is returned by decvonvolving the rfn
% from itself
%

if( nargin < 1 ), isprompt = false; end
  
% read data
[t,zseis,hdrZ]=sac2mat('test_data/lac_sp.z');
[t,rseis,hdrR]=sac2mat('test_data/lac_sp.r');


% get time axis
t0 = hdrZ.times.b
dt = hdrZ.times.delta
nt = hdrZ.trcLen
time = t0 + dt*(0:1:(nt-1));

% plot data and wait for user input
figure(1);
clf;
subplot(2,1,1); plot( time, zseis ); axis tight; legend('Z')
subplot(2,1,2); plot( time, rseis ); axis tight; legend('R')
xlabel('Time (s)')
% tmp=input('prompt after plotting components.');

% make receiver function
tdel=5; %RF starts at 5 s
f0 = 2.5; % pulse width
niter=100;  % number iterations
minderr=0.001;  % stop when error reaches limit

%--------------------------------------------------
%%% Ligorria and Ammon method
disp('Ligorria & Ammon method ')
[rfi1, rms1] = makeRFitdecon_la( rseis, zseis, ...
				 dt, nt, tdel, f0, ...
				 niter, minderr);
% update the time
time = - tdel  + dt*(0:1:nt-1);

% deconvolve from itself
[rfi1, rms1] = makeRFitdecon_la( rfi1, rfi1, ...
				 dt, nt, tdel, f0, ...
				 niter, minderr);

% compute the area under the gaussian
areaUnder = sum( rfi1 )*dt 
% plot
clf;
h1 = plot(time,rfi1,'k'); hold on;

if( isprompt ),
  tmp=input('prompt after plotting Ligorria & Ammon method.');
end


%--------------------------------------------------
% Iain method
minlag=0;
maxlag=12.7;
disp('IWB method ')
[rfi3, rms3] = makeRFitdecon( rseis, zseis, dt, ...
			      minlag, maxlag,...
			      tdel, f0, niter, minderr, 0);

% double the length of the signal so that we don't cut it out
nt = numel(rfi3);
rfi3 = [ rfi3, zeros(1,nt) ];

[rfi3, rms3] = makeRFitdecon( rfi3, rfi3, dt, ...
			      minlag, maxlag,...
			      tdel, f0, niter, minderr, 0);

time=-tdel + dt*(0:1:(length(rfi3)-1));

areaUnder = sum( rfi3 )*dt 
h4 = plot(time,rfi3,'r'); hold on;

if( isprompt ),
  tmp=input('prompt after IWB result.');
end

%--------------------------------------------------
% Frequency domain
wlevel=1e-4;

%--------------------------------------------------
% Ammon method
disp('Ammon freq domain method ')
%wlevel=1e-8;
[rfi5,tmp] = makeRFwater_ammon( rseis, zseis, tdel, dt, nt, wlevel, f0);
[rfi5,tmp] = makeRFwater_ammon( rfi5, rfi5, tdel, dt, nt, wlevel, f0);

areaUnder = sum( rfi5 )*dt 
h6 = plot(time,rfi5,'--b','LineWidth',2); hold on;

%--------------------------------------------------
legend([ h1, h4, h6 ], ...
       'L&A - matlab',...
       'IWB - 1',...
       'Ammon Water Level method')

axis tight



% 
% xlabel('Time (s)')
% 
