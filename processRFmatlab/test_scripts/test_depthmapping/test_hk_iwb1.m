%function test_hk_iwb
%
% test the matlab h-k stacking using the same example as given by Zhu with his codes

% Parameters used in example
h=20:0.5:60;
kappa=1.5:0.01:2.0;
w = [ 0.7, 0.2, 0.1 ] ;% weighting matrix
%w = [ 1, 1, 1 ] ;% weighting matrix
vp=6.3;

% read data
DIR='./example/';
[t, p, rfdata] = readData( DIR, dir( [DIR,'*ri'] ) );
t0 = t(1);
dt = t(2)-t(1);

% do the hk stacking
[stack, stackvar, stack_all, stackall_var ] = hkstack_iwb( rfdata, t0, dt, p, h, kappa, vp,w );

% combine the stacks 
allstack = w(1)*stack(:,:,1) + w(2)*stack(:,:,2) + w(3)*stack(:,:,3);
[maxA, i] = max(max(allstack));
[i,j] = find( allstack == maxA ,1);
besth = h(j);
bestk = kappa(i);
onesigma = maxA - sqrt(stackall_var(i,j));
fprintf('Best h = %.2f, best kappa = %.2f\n', [besth,bestk] )

% plot 3 stacks
figure(1); clf;
for i =1:3,
  subplot(2,3,i); hold on;
  imagesc(h, kappa, stack(:,:,i)); 
  plot( besth, bestk, 'kx', 'MarkerSize',10,'LineWidth',3)
  axis tight
  cb = colorbar('peer',gca);
  subplot(2,3,i+3); hold on;
  imagesc(h, kappa, stackvar(:,:,i)); 
  plot( besth, bestk, 'kx', 'MarkerSize',10,'LineWidth',3)
  axis tight
  cb = colorbar('peer',gca);
  
end

% plot combined stack
figure(2); clf;
imagesc(h, kappa, allstack); hold on;
plot( besth, bestk, 'kx', 'MarkerSize',10,'LineWidth',3)
tempstr = num2str(onesigma);
onesigma = str2double(tempstr(1:5));
%contour(h,kappa,stack_all,[onesigma],'ShowText','on','linestyle','-','linewidth',1.0,'linecolor','k');
axis tight
cb = colorbar('peer',gca);
set(gca,'YDir','normal')
ylabel( 'Vp/Vs' )
xlabel( 'H (km)' )

% plot the data 
nrf = numel(p);
[p, sorti] = sort(p);
for i=sorti,
  times{i} = t;
  seiss{i} = rfdata(:,i);
end

figure(3); clf;
% plot the locations of the conversion and multiples
eta_p = vslow( vp, p);  % get vp vertical slowness
eta_s = vslow( vp./bestk, p ); % get vertical slowness for all vs
plot(p, tPs(besth, eta_p, eta_s ), '--k', 'linewidth',2 ); hold on;
plot(p, tPpPs(besth, eta_p, eta_s ), '--k', 'linewidth',2 )
plot(p, tPsPs(besth, eta_s ), '--k', 'linewidth',2 )

% plot the seismograms
plotRFgather_rayp( times, seiss , p, zeros(1,nrf), nrf , 50, false); hold on;

v = axis;
tmax = 30; % max time to plot
axis([v(1), v(2), v(3), tmax])


%return
%--------------------------------------------------

