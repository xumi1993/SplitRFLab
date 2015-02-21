function test_map2depth
% test that the ray paths are correct in the mapping to depth

addpath ../
addpath ../../velmodels1D/

% use the AK135 continental model
[vmod.z, ~, vmod.vp, vmod.vs, ~, ~ ] = ak135( 'cont' );

zmax = 300; % max depth to plot
p = 0.05; % slowness
backaz = 0; % back azimuth 
dz = 1.0; % depth interval (km)
zc = 100; % conversion depth


% get the path of P and S
[eposs,nposs,zposs] = sRaypath_1d( p, backaz, dz, zmax, vmod.z, vmod.vs );
[eposp,nposp,zposp] = pRaypath_1d( p, backaz, dz, zmax, vmod.z, vmod.vp );

% combine rays
idx = find( zposs <= zc );
eposs = eposs(idx); nposs = nposs(idx); zposs = zposs(idx);
epc = eposs(end); npc = nposs(end); zpc = zposs(end);

idx = find( zposp >= zc );
eposp = eposp(idx); nposp = nposp(idx); zposp = zposp(idx);
eposp = eposp - eposp(1) + epc;
nposp = nposp - nposp(1) + npc;
zposp = zposp - zposp(1) + zpc;

figure(1);
clf;
subplot(1,2,1);
plot( nposp, zposp, '-r' ); hold on;
plot( nposs, zposs, '-b' ); hold on;
set(gca, 'YDir','reverse');
legend('P-wave', 'S-wave');
axis equal;

subplot(1,2,2);
plot( vmod.vp( vmod.z<zmax ), vmod.z(vmod.z<zmax), '-r' ); hold on;
plot( vmod.vs( vmod.z<zmax ), vmod.z(vmod.z<zmax), '-b' );

set(gca, 'YDir','reverse');

% now change the ray parameter
p = 0.11

% get the path of P and S
[eposs,nposs,zposs] = sRaypath_1d( p, backaz, dz, zmax, vmod.z, vmod.vs );
[eposp,nposp,zposp] = pRaypath_1d( p, backaz, dz, zmax, vmod.z, vmod.vp );

% combine rays
idx = find( zposp <= zc );
eposp = eposp(idx); nposp = nposp(idx); zposp = zposp(idx);
epc = eposp(end); npc = nposp(end); zpc = zposp(end);

idx = find( zposs >= zc );
eposs = eposs(idx); nposs = nposs(idx); zposs = zposs(idx);
eposs = eposs - eposs(1) + epc;
nposs = nposs - nposs(1) + npc;
zposs = zposs - zposs(1) + zpc;

figure(2);
clf;
subplot(1,2,1);
plot( nposp, zposp, '-r' ); hold on;
plot( nposs, zposs, '-b' ); hold on;
set(gca, 'YDir','reverse');
legend('P-wave', 'S-wave');
axis equal;

subplot(1,2,2);
plot( vmod.vp( vmod.z<zmax ), vmod.z(vmod.z<zmax), '-r' ); hold on;
plot( vmod.vs( vmod.z<zmax ), vmod.z(vmod.z<zmax), '-b' );

set(gca, 'YDir','reverse');
