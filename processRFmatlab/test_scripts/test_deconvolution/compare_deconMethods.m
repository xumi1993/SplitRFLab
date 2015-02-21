function compare_deconMethods
%
% test the matlab iterative deconvolution using the same example as
% given by Ammon with his codes

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

% receiver function parameters
tdel=5; %RF starts at 5 s
f0 = 2.5; % pulse width
niter=100;  % number iterations
minderr=0.001;  % stop when error reaches limit

% update the time
time = - tdel  + dt*(0:1:nt-1);

% ----------
%%% Ligorria and Ammon method
disp('Ligorria & Ammon Method...')
[rfi1, rms1] = makeRFitdecon_la( rseis, zseis, ...
				 dt, nt, tdel, f0, ...
				 niter, minderr);

% overwrite  the plot with new RF
clf;
h1 = plot(time,rfi1,'k'); hold on;



% ----------
%%% Iain method
disp('IWB Iterative Method...')
minlag=0;
maxlag=12.7;
[rfi3, rms3] = makeRFitdecon( rseis, zseis, dt, ...
			      minlag, maxlag,...
			      tdel, f0, niter, minderr, 1);
time2=-tdel + dt*(0:1:(length(rfi3)-1));
h2 = plot(time2,rfi3,'r'); hold on;

% tmp=input('prompt after IWB result.  No wraparound in convolutions/correlations');

% ----------
%%% Frequency domain
wlevel=1e-2;


% ----------
disp('Ammon et al Water level Method...')
[rfi5,rms5] = makeRFwater_ammon( rseis, zseis, tdel, dt, nt, wlevel, f0);
h3 = plot(time,rfi5,'--b','LineWidth',2); hold on;

% ----------
legend([ h1, h2, h3 ], ...
       'L&A - matlab',...
       'IWB - 1',...
       'Ammon Water Level method')

axis tight

xlabel('Time (s)')

figure(2); clf;
h1 = semilogy(rms1,'.k'); hold on;
h3 = semilogy(rms3,'.r');

legend([ h1, h3 ], 'L&A - matlab','IWB')
xlabel('Iteration Number')
ylabel('Scaled Sum Sq Error')

% Display the RMS values
fprintf('\nFinished\n')
fprintf('RMS for Ligorria/Ammon method:\t\t %f\n', rms1(end))
fprintf('RMS for IWB Iterative method:\t\t %f\n', rms3(end))
fprintf('RMS for Ammon W. Level method:\t\t %f\n', rms5)
