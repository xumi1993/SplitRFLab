function test_hk
%
% test the matlab h-k stacking using the same example as given by Zhu with his codes

% Parameters used in example
h=20:0.5:60;
kappa=1.5:0.01:2.0;
ismooth = 1.0;
W = [ 0.7, 0.2, 0.1 ] ;% weighting matrix
vp=6.3;

% read data
DIR='./example/';
[t, p, rfdata] = readData( DIR, dir( [DIR,'*ri'] ) );
t0 = t(1);
dt = t(2)-t(1);

% clf; plot( t, rfdata(:,1) ); xlabel('Time(s)'); hold on;
% pause

% plot input data
clf;
plot( t, rfdata ); xlabel('Time(s)'); hold on;
axis tight;
% pause

% do the hk stacking
[stack, stackvar,besth, bestk ] = hkstack( rfdata, t0, dt, p, h, kappa, vp , ...
				  W , ismooth, false);
stack = -1*stack;
fprintf('Best h = %.2f, best kappa = %.2f\n', [besth,bestk] )

figure(1); clf;
%contourf(kappa, h, grid); hold on;
imagesc(h, kappa, stack); hold on;
plot( besth, bestk, 'kx', 'MarkerSize',10,'LineWidth',3)
ylabel( 'Vp/Vs' )
xlabel( 'H (km)' )
set(gca,'YDir','normal')
grid on
cb = colorbar('peer',gca);
set( get(cb, 'ylabel'), 'String','Weighted Amplitude')


% Get the output from the C program
fout = load('zhu_example_out.xyz'); % fortran output
fout = sortrows( fout, [1,2] );
zi = griddata( fout(:,1), fout(:,2), fout(:,3) , h, kappa');

% get best 
[ minz, jdx] =  min( fout(:,3) );
fprintf('Best h = %.2f, best kappa = %.2f\n', [fout(jdx,1:2)] )

% plot
figure(2); clf;
imagesc(h, kappa, zi); hold on;
plot( fout(jdx,1), fout(jdx,2), 'kx', 'MarkerSize',10,'LineWidth',3)
set(gca,'YDir','normal')
ylabel( 'Vp/Vs' )
xlabel( 'H (km)' )

% add colour bar
cb = colorbar('peer',gca);
set( get(cb, 'ylabel'), 'String','Something')

% plot difference 
mindiff = min( min( stack - zi ) )
maxdiff = max( min( stack - zi ) )
% surf( fout(:,1), fout(:,2), fout(:,3) )



return
%--------------------------------------------------
function [time, p, rfdata] = readData( DIR, filelist )
% read in the rfn data
%
% get the time, slowness and seismograms
%

nrfn = length(filelist); % number of receiver functions
[time,rfseis,hdr]=sac2mat( [DIR, filelist(1).name]);
npts = length(rfseis); % number of data points

% make container of rf data and slowness
rfdata = zeros(npts,nrfn);  
p = zeros(1,nrfn);

p(1) = hdr.user(1).data; % slowness is in user0
rfdata(:,1) = rfseis;
for k=2:nrfn,
  [time,rfseis,hdr] = sac2mat([DIR, filelist(k).name]);
  rfdata(:,k) = rfseis;
  p(k) = hdr.user(1).data;
end

return
% %--------------------------------------------------
% function [rfdata] = smoothSeis2( rfdata, ismooth )
% 
% % Apply smoothing to the receiver functions, as done in the Zhu code
% % See fft.c of zhu's code
% dt =1;
% 
% rfdata2 = rfdata;
% nt = size( rfdata, 1 );
% 
% if( ismooth > 0 )
%   for i=1:1+ismooth-1,
%     rfdata2(i,:) = sum( rfdata(1:i+ismooth,:) )./((ismooth+1)*dt);
%     rfdata2(end-i+1,:) = sum( rfdata(end-ismooth:end,:) )./((ismooth+1)*dt);
%   end
% end
% 
% for i=1+ismooth:nt-ismooth,
%   rfdata2(i,:) = sum( rfdata(i-ismooth:i+ismooth,:) )./((2*ismooth+1)*dt);
% end
% 
% rfdata = rfdata2;
% 
% return
% %--------------------------------------------------
% function [rfdata] = smoothSeis( rfdata, ismooth )
% 
% % Apply smoothing to the receiver functions, as done in the Zhu code
% % See fft.c of zhu's code
% dt =1;
% 
% rfdata2 = rfdata;
% nt = size( rfdata, 1 );
% 
% for i =1:nt,
%   i1=max(i-ismooth,1);
%   i2=min(i+ismooth,nt);
%   
%   ip = i1+1;
%   dd = ip - i1;
%   disp
%   rfdata2(i,:) = dd*( dd*rfdata(i1,:) + (2 - dd)*rfdata(ip,:) );
%   
%   while( ip < i2 ),
%     rfdata2(i,:) = rfdata2(i,:) + rfdata2(ip+1,:);
%     ip = ip+1;
%   end
%   
%   dd = ip-i2;
%   rfdata2(i,:) = rfdata2(i,:) - dd*( dd*rfdata(ip-1,:) + (2 - dd)*rfdata(ip,:) );
%   rfdata2(i,:) = 0.5*rfdata2(i,:);
% end
% 
% rfdata = rfdata2;
% 
% return
