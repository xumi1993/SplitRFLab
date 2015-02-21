function testDamp
%
% test different damping levels for the damped method

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

% damping
damp = [1e-3 5e-3 1e-2 5e-2 1e-1 5e-1 1 5 ];
nrf = numel(damp);
rf = zeros(nrf,nt);
rms = zeros(nrf,1);
for i = 1:nrf,
  [rf(i,:),rms(i)] = makeRFdamp( rseis, zseis, tdel, dt, nt, damp(i), f0, true);
  fprintf('RMS: %.2f\n', rms(i))
end



%--------------------
% plot results
figure(1); clf;
semilogx( damp, rms ,'.-k')
xlabel('Damp');
ylabel('RMS fit')

for i = 1:nrf,
  figure(i+1); clf;
  h1 = plot(time,rf(i,:), 'linewidth', 2 ); hold on;
  title('Damped')
  legend(num2str(damp(i)))
  axis tight
  xlabel('Time (s)')
end
