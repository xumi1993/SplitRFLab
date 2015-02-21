function test_gaussian()
% check the f0 and frequencies and ulsewidths matcha up
% from itself
%

% set constant arguments
dt = 0.1;
nft = 128;
delay = 5; % delay in 5 seconds

% frequencies to test
f0 = [ 0.2, 0.4, 0.5, 0.625, 0.75, 1.0, 1.25, 1.5, 2.5, 5, 10 ];

% compute time
t = 0.0 + dt*(0:1:(nft-1));

% set up matrices
nf = numel(f0);
thw = zeros( nf, 1 ); 
gt = zeros(nft,nf);

% loop through frequencies
for i = 1:nf,
  
  fprintf('f0 = %.2f\n', f0(i))
  
   % make a gaussian filter
  g = gaussFilter( dt, nft, f0(i) );

  % get the freq where amplitude is 0.1
  [~, fi2] = min( abs( g - 0.1*max(g) ) );
  fprintf('f(g = 0.1) = %f Hz \n',fi2/(nft*dt))

  % inverse ft
  gt(:,i) = abs( ifft( g, nft ) );

  % time shift
  [~, gt(:,i)] = shiftSeis( gt(:,i), 0.0, dt, delay, true );

  fprintf( 'Area under trace: %f\n', sum( abs(gt(:,i)) )*dt )
  
  % compute the full width at half the maximum
  [Amax, ti1] = max(gt(:,i));
  [~, ti2] = min( abs( gt(:,i) - 0.5*Amax ) );
  thw(i) = 2*dt*abs(ti2-ti1);
  fprintf( 'Estimated width between 0.5Amax: %.2f\n\n', thw(i) );
  

end

% plot results
figure(1); clf;
subplot(2,1,1); 
plot( t, gt ); hold on;
xlabel('Time (s)');
axis tight;

subplot(2,1,2);
for i=1:nf,
  plotSpectrum( gt(:,i), dt ); hold on;
end
axis tight;

% Compare to what it should be
figure(2); clf;
plot( thw, 2*sqrt(log(2.0))./f0 ,'.k'); hold on;
plot([0,5],[0,5],'--r')
axis([0,5,0,5])
axis square
xlabel('Estimated pulse width (s)')
ylabel('Predicted pulse width (s)')

return

