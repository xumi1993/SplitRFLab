function testHighpass
%
% Test bandpass on example data

% read in the data
prefix='test_data/TA.Q20A'  % prefix of for 3 components to open

% Read  in the z component 
[tz, zseis, zhdr] = sac2mat( [prefix, '.BHZ'] );
dt = zhdr.times.delta; % sample interval

zseis = taperSeis( zseis, 0.1 );

% plot the seismogram
figure(1);clf;
plot( tz, zseis, '-k');
xlabel('Time (s)');  

% plot the spectrum
zhdr.times.delta;
figure(2); clf;
plotSpectrum( zseis, dt ) 

% high pass
fhp = 0.01;
norder = 4;
zseis1 = highpassSeis( zseis, dt, fhp, norder);

% plot spectrum 
figure(2); hold on;
plotSpectrum( zseis1, dt ,'-r') 

% plot seis
figure(1); hold on;
plot( tz, zseis1, '-r');
axis tight;

% different high pass
fhp = 0.2;
norder = 3;
zseis2 = highpassSeis( zseis, dt, fhp, norder);

% plot seis
figure(1); hold on;
plot( tz, zseis2, '-b');
axis tight;

% plot 
figure(2); hold on;
plotSpectrum( zseis2, dt ,'-b') 

legend('Starting', 'First example highpass', '2nd example highpass' )
legend boxoff
