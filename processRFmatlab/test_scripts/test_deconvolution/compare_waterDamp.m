function compare_waterDamp
%
% compare the water level deconvolution method to damped method

% read data
[Zin,hdrZ]=sacsun2mat('test_data/uln_1995_113_b_057_d_045.z');
[Ein,hdrE]=sacsun2mat('test_data/uln_1995_113_b_057_d_045.e');
[Nin,hdrN]=sacsun2mat('test_data/uln_1995_113_b_057_d_045.n');

% get time axis
t0 = hdrZ.times.b;
dt = hdrZ.times.delta;
nt = hdrZ.trcLen;
baz = hdrZ.evsta.baz;
time = t0 + dt*(0:1:(nt-1));
% hdrZ.times

% % plot data and wait for user input
% figure(1);
% clf;
% plot3seis( time, Zin, time, Ein, time, Nin )

% tmp=input('prompt after plotting components.');

% rotate to ZRT coordinates
seis = rotateSeisENZtoTRZ( [Ein, Nin, Zin] , baz );
rseis = seis(:,2);
zseis = seis(:,3);

% Receiver function parameters from Ammon's readme file
tdel = 30; 
f0 = 1.0; % pulse width
wlevel = 0.05; % can't tell from readme, chosen based on best fit

%--------------------
% Make receiver function

% water level
wlevel = [1e-3 5e-3 1e-2 5e-2 1e-1];
nrf = numel(wlevel);

rf1 = zeros(nrf,nt);
for i = 1:nrf,
  [rf1(i,:),rms] = makeRFwater( rseis, zseis, tdel, dt, nt, wlevel(i), f0, true);
  fprintf('RMS: %.2f\n', rms)
end

% damped
damp = wlevel

rf2 = zeros(nrf,nt);
for i = 1:nrf,
  [rf2(i,:),rms] = makeRFdamp( rseis, zseis, tdel, dt, nt, damp(i), f0, true);
  fprintf('RMS: %.2f\n', rms)
end



%--------------------
% plot results
clf;
subplot(2,1,1); 
h1 = plot(time,rf1, 'linewidth', 2); hold on;
title('Water Level')
axis tight

subplot(2,1,2);
h1 = plot(time,rf2, 'linewidth', 2); hold on;
title('Damped')

axis tight

xlabel('Time (s)')

