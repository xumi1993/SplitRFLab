function testBandpass
%
% Test bandpass on example data

% read in the data
prefix='test_data/TA.Q20A'  % prefix of for 3 components to open

% Read  in the z component 
[tz, zseis, zhdr] = sac2mat( [prefix, '.BHZ'] );
dt = zhdr.times.delta; % sample interval

% plot the seismogram
figure(1); clf;
plot( tz, zseis, '-k');
xlabel('Time (s)');  

% plot the spectrum
figure(2); clf;
plotSpectrum( zseis, dt ) 

% bandpass
fhp = 0.02;
flp = 5.0;
norder = 2;
zseis1 = bandpassSeis( zseis, dt, fhp, flp , norder);

% plot the seismogram
figure(1); hold on;;
plot( tz, zseis1, '-r');

% plot the spectrum
figure(2); hold on;;
plotSpectrum( zseis1, dt , '-r') 

fhp = 0.1;
flp = 2;
norder = 3;
zseis2 = bandpassSeis( zseis, dt, fhp, flp , norder);

% plot 
figure(1); hold on;;
plot( tz, zseis2, '-b');
figure(2); hold on;;
plotSpectrum( zseis2, dt ,'-b') 

legend('Starting', 'First example bandpass', '2nd example bandpass' )
legend boxoff

