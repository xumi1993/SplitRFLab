function test_ligAmmon
%
% Compare the output from fortran code and my matlab version

% read data
[t,zseis,hdrZ]=sac2mat('test_data/lac_sp.z');
[t,rseis,hdrR]=sac2mat('test_data/lac_sp.r');

% get time axis
t0 = hdrZ.times.b;
dt = hdrZ.times.delta;
nt = hdrZ.trcLen;
time = t0 + dt*(0:1:(nt-1));

% plot data and wait for user input
figure(1);
clf;
subplot(2,1,1); plot( time, zseis ); axis tight; legend('Z')
subplot(2,1,2); plot( time, rseis ); axis tight; legend('R')
xlabel('Time (s)')
% tmp=input('prompt after plotting components.');

% Receiver function parameters
tdel = 5; %RF starts at 5 s
f0 = 2.5; % pulse width
niter = 100;  % number iterations
minderr = 0.001;  % stop when error reaches limit

% Make receiver function
[rfi1, rms1] = makeRFitdecon_la( rseis, zseis, dt, nt, tdel, f0, ...
				 niter, minderr);

% get time for RF
time = - tdel  + dt*(0:1:nt-1);

% plot RF
clf;
h1 = plot(time,rfi1,'k'); hold on;

% plot the fortran output
[t,data, hd] = sac2mat('test_data/lac.i.eqr');  % open the output from file
h2 = plot(t,data,'--g'); hold on;

% plot the legend and labels
legend([ h1, h2 ],'L&A - matlab','L&A - fortran' )
xlabel('Time (s)')
axis tight

% plot the RMS from the iterations
figure(2); clf;
h1 = semilogy(rms1,'.k'); hold on;
legend([ h1 ], 'L&A - matlab')
xlabel('Iteration Number')
ylabel('Scaled Sum Sq Error')