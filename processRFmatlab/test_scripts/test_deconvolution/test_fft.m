function test_fft()

% check the fft makes sense

% For a gaussian pulse in time  f(t) = a exp{-pi (a t)^2} the fourier
% transform is F(f) = a exp{ -pi(f/a)^2 }
%
% this also works in reverse


dt = 0.1;
t=0:dt:10;
tmid=5;
nt=numel(t);
a = 1.5;
f0 = 2.5;

fprintf('fn: f(t) = a exp{-pi (a (t-tmid))^2}, with a = %.2f\n', a );
xt = a* exp( -pi*(a*(t-tmid)).^2 ) ; 

figure(1); clf;
plot( t, xt ); hold on;

% compute standard deviation
s = 1/(a*sqrt(2*pi));
fprintf('equivalent to normpdf(t,0,1/(a*sqrt(2*pi)))\n');

plot( t, normpdf(t, 5, s),'--r' ); 

% compute width at half max amplitude
% width = 2 sqrt(2 ln 2 ) sigma
w = s*(2*sqrt(2*log(2)));

fprintf('Width at 1/2 max amplitude: %.2f\n', w );
plot( [5-0.5*w, 5+0.5*w ], 0.5*max(xt).*[1,1], '-g')
xlabel('Time (s)')

% compute the fourier transform
nft = 2^nextpow2(nt );
xf = fft( xt, nft)*dt;
f = (1/(2*dt))*linspace(-1,1,nft+1);
f = f(1:end-1); % frequencies 

% plot
figure(2); clf;
fprintf('\nCompare numerical fourier transform\n')
plot( f, abs(fftshift(xf))); hold on;
fprintf('to analytical soln: F{f(t)} = exp{-pi (f/a)^2}\n');
plot( f, exp( -pi*(f/a).^2), '--r'); 
xlabel('f (Hz)')
fprintf('equivalent to a * normpdf(t,0,a/(sqrt(pi*2)), where std. dev = %.2f\n', a/(sqrt(pi*2)) )

plot( f, a*normpdf(f, 0.0, a/(sqrt(pi*2))) ,'.g')

% now do this in reverse 
fprintf( '\nNow consider the inverse fourier transform\n' )
fprintf('If F^-1{ exp{-pi (f/a)^2} } = a exp{-pi (a (t-tmid))^2} \n')
fprintf( '\nthen F^-1{ exp{-(2 pi f)^2 / 4f0^2} } = (f0/sqrt(pi)) exp{-(f0 t)^2} \n')

fprintf('f0 is the frequency where the filter amplitude is exp{-pi^2} = %.4g\n', exp(-pi^2) )

fprintf('\nConsider f0 = %.2f\n', f0 )

xf = exp( -((2*pi*f).^2)/(4*f0^2) );
figure(3); clf;
subplot(2,1,1);
plot(f, xf,'-k'); hold on;
xlabel('f (Hz)')

% compute equivalent norm pdf
fprintf('exp{-(2 pi f / 4f0)^2} = (f0/sqrt(pi)) * normpdf(t,0, f0/pi/sqrt(2))\n' )
s_f = f0 /(pi*sqrt(2));
plot( f, sqrt(2*pi)*s_f*normpdf(f, 0.0, s_f), '--r')

% compute the fourier transform
xt = abs( ifft( xf, nft ) )/dt;
subplot(2,1,2);
plot( t, xt(1:nt), '-k' ); hold on;

% plot the analytical solution
plot( t, (f0/sqrt(pi))*exp(-(f0.*t).^2),'--r' );
fprintf('(f0/sqrt(pi))*exp(-(f0.*t).^2) = normpdf(t, 0.0, 1/(sqrt(2)*f0) ) \n' )
plot( t, normpdf( t, 0.0, sqrt(0.5)/f0 ), '.g')

xlabel('Time (s)')

tw = (1/(f0))*(2*sqrt(log(2)));

% full width at half max given by 2 sqrt(2*ln(2)) sigma
fprintf('Width at half max amplitude = 2*sqrt(log(2))/f0 =~ 1.67/f0\n' )
fprintf('So for f0 = %.2f, width = %.2f s\n\n', [f0, tw] ) 
plot([0,0.5*tw], 0.5*(f0/sqrt(pi))*[1,1], '-b')

return

