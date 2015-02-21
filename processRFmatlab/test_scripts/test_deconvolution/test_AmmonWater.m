function test_AmmonWater
%
% Compare the output from fortran code and my matlab version

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

% plot data and wait for user input
figure(1);
clf;
plot3seis( time, Zin, time, Ein, time, Nin )

% tmp=input('prompt after plotting components.');

% rotate to ZRT coordinates
seis = rotateSeisENZtoTRZ( [Ein, Nin, Zin] , baz );
rseis = seis(:,2);
zseis = seis(:,3);

% Receiver function parameters from Ammon's readme file
tdel = 30; 
f0 = 1.0; % pulse width
wlevel = 0.001; % can't tell from readme, chosen based on best fit

% Make receiver function
[rf1,rms] = makeRFwater_ammon( rseis, zseis, tdel, dt, nt, wlevel, f0);

% get time for RF
time = - tdel  + dt*(0:1:numel(rf1)-1);

% plot RF
clf;
h1 = plot(time,rf1,'k'); hold on;

% plot the fortran output
[RFin,hdrZ]=sacsun2mat('test_data/ULN_TEST.eqr');
t0 = hdrZ.times.b;
dt = hdrZ.times.delta;
nt = hdrZ.trcLen;
t = t0 + dt*(0:1:(nt-1));
h2 = plot(t,RFin,'--g'); hold on;

% plot the legend and labels
legend([ h1, h2 ],'Ammon - matlab','Ammon - fortran' )
xlabel('Time (s)')
axis tight

% deconvolve itself
[gnorm,rms] = makeRFwater_ammon( rf1, rf1, tdel, dt, nt, wlevel, f0);
sumArea = sum(gnorm)*dt
figure(2); clf;
plot(time, gnorm)
axis tight
xlabel('Time (s)')
title('RF deconvolved from itself')
%
disp(['There is a difference in amp b/c we use unit area gaussian. ',...
      'The fortran program uses unit amplitude.  A switch for this is in the program.',...
      ' A slight difference in peaks remains but is probably due to ',...
      'numerical diffs??'])

% Investigate changes in f0
figure(3); clf;
f0 = [ 0.5, 0.75, 1.0, 1.5, 2.0 ];
wl = [ 2e-4, 5e-4, 1e-3, 1e-2, 1e-1, 2e-1, 50];
lt = strvcat('-r', '-o', '-g', '-b', '-k' );  
nf = numel(f0);
nw = numel(wl);
rfs = zeros( nt, nf, nw );
rmss = zeros( nf, nw );

for i=1:nf,
  for j=1:nw,
    [rfs(:,i,j),rmss(i,j)] = makeRFwater_ammon( rseis, zseis, tdel, dt, nt, ...
						wl(j), f0(i),false);
    fprintf('wlevel: %.1e, f_0: %.2f, rms: %.3f\n', [wl(j), f0(i), rmss(i,j)] )
    plot( time, rfs(:,i,j) ,'-c'); hold on;    
  end

end

% legend(num2str(f0(1)),num2str(f0(2)),num2str(f0(3)),num2str(f0(4)),...
%        num2str(f0(5)) );

% best ??
besti=3; bestj=3;
fprintf('Overlaying f0 = %.1f and wl = %.1e in red\n', [f0(besti),wl(bestj)])
plot( time, rfs(:,besti,bestj), '-r', 'Linewidth',2 )

fprintf('Overlaying mean of all f0 = %.1f in blue\n', [f0(besti)])
plot( time, mean(rfs(:,besti,:),3), '-b', 'Linewidth',2 )
xlabel('Time (s)')
title('Different values of f_0 and water level')

axis tight

% out of interest, what is it like if water level is 1
[rfi,rms] = makeRFwater_ammon( rseis, zseis, tdel, dt, nt, ...
			       50, 1,true);

plot( time, rfi, '-k', 'Linewidth',2 )
