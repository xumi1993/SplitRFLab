function test_iter
% test my iterative decon code

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
%%% Iain method
disp('IWB Iterative Method...')
minlag=0;
maxlag=12.7;
[rfi, rms] = makeRFitdecon( rseis, zseis, dt, ...
			      minlag, maxlag,...
			      tdel, f0, niter, minderr, 1);
time=-tdel + dt*(0:1:(length(rfi)-1));
clf
h1 = plot(time,rfi,'r'); hold on;

% tmp=input('prompt after IWB result.  No wraparound in convolutions/correlations');


axis tight

xlabel('Time (s)')

figure(2); clf;
h1 = semilogy(rms,'.k'); hold on;

xlabel('Iteration Number')
ylabel('Scaled Sum Sq Error')

% Display the RMS values
fprintf('\nFinished\n')
fprintf('RMS for IWB Iterative method:\t\t %f\n', rms(end))
