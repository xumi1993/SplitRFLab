function testRotation
%
% Simple test of rotation function

% make a three component seismogram
dt=1;
t = -100:dt:100;
sigma = 2;

% make a wavelet
t0 = [ t(1)-dt, t, t(end)+dt ];
zseis = normpdf( t0, 0, sigma );
zseis = -diff( diff( zseis ) );
zseis = zseis/max( zseis );

% make same amplitude in all directions
nseis = zseis/sqrt(2.0);
eseis = zseis/sqrt(2.0);

clf;
title('Z-N-E')
plot3seis( t, eseis, t, nseis, t, zseis, ['E'; 'N'; 'T'] );
tmp = input('plotted initial wave form. Press key to continue\n');

% back azimuth and incidence in degrees
baz = -135;
inc = 45;

% rotate into TRZ coordinates
[trzseis, key] = rotateSeisENZtoTRZ( [eseis',nseis',zseis'], baz );

plot3seis( t, trzseis(:,1), t, trzseis(:,2), t, trzseis(:,3), key );

tmp = input('Rotated into TRZ. Press key to continue\n');


% rotate into TLQ coordinates
[tlqseis, key] = rotateSeisTRZtoTLQ( trzseis, inc );

plot3seis( t, tlqseis(:,1), t, tlqseis(:,2), t, tlqseis(:,3), key );

% check the rotation applies in the frequency domain
zseisf = fft( zseis );
nseisf = fft( nseis );
eseisf = fft( eseis );

[trzseisf, key] = rotateSeisENZtoTRZ( [eseisf.',nseisf.',zseisf.'], baz );
tseis = real( ifft( trzseisf(:,1) ) );
lseis = real( ifft( trzseisf(:,2) ) );
qseis = real( ifft( trzseisf(:,3) ) );

plot3seis( t, tseis, t, lseis, t, qseis, key );
tmp = input('Rotated into TRZ in freq domain. Press key to continue\n');

[tlqseisf, key] = rotateSeisTRZtoTLQ( trzseisf, inc );

tseis = real( ifft( tlqseisf(:,1) ) );
lseis = real( ifft( tlqseisf(:,2) ) );
qseis = real( ifft( tlqseisf(:,3) ) );

plot3seis( t, tseis, t, lseis, t, qseis, key );
fprintf('Rotated into TLQ in freq domain.\n')


