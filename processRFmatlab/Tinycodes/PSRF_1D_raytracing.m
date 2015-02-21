function [x_s, x_p, raylength_s, raylength_p, Tpds]=PSRF_1D_raytracing(datar, rayp, YAxisRange)

RFlength = size(datar,1); EV_num = size(datar, 2);

%% Model information
Velocity1D='/Users/xumj/Documents/MATLAB/ccp/VEL_models/AK135.vel';
VelocityModel = load(Velocity1D,'-ascii');


% Depths
%--------------------------------------------------------------------------
Depths = VelocityModel(:,1);
% Velocities
%--------------------------------------------------------------------------
Vp = VelocityModel(:,2);
Vs = VelocityModel(:,3);
% Interpolate velocity model to match depth range and increments
%--------------------------------------------------------------------------
Vp = interp1(Depths,Vp,YAxisRange)';
Vs = interp1(Depths,Vs,YAxisRange)';
Depths = YAxisRange';

% Depth intervals
%--------------------------------------------------------------------------
dz = [0; diff(Depths)];
% Radial shells
%--------------------------------------------------------------------------
R = 6371 - Depths;

%% 1D ray tracing:
%--------------------------------------------------------------------------
    x_s=zeros(length(YAxisRange),EV_num);
    x_p=zeros(length(YAxisRange),EV_num);
    raylength_s=zeros(length(YAxisRange),EV_num);
    raylength_p=zeros(length(YAxisRange),EV_num);
    Tpds=zeros(length(YAxisRange),EV_num);

for i = 1:EV_num  
    
    x_s(:,i) = cumsum((dz./R) ./ sqrt((1./(rayp(i)^2.* (R./Vs).^-2)) - 1)); %Pds piercing distance from station in rad
    raylength_s(:,i) = (dz.*R) ./  (sqrt(((R./Vs).^2) - (rayp(i)^2)).* Vs); %ray length of S in each layer
    x_p(:,i) = cumsum((dz./R) ./ sqrt((1./(rayp(i)^2.* (R./Vp).^-2)) - 1)); %Pdp piercing distance from station in rad
    raylength_p(:,i) = (dz.*R) ./  (sqrt(((R./Vp).^2) - (rayp(i)^2)).* Vp); %ray length of P in each layer
    
    
    Tpds(:,i) = cumsum((sqrt((R./Vs).^2 - rayp(i)^2) - sqrt((R./Vp).^2 - rayp(i)^2)) .* (dz./R));
    
    
     StopIndex = find(imag(x_p(:,i)),1);
    if ~isempty(StopIndex)
        x_p(StopIndex:end,i) = NaN * ones(length(x_p(:,i))-StopIndex+1,1);
        x_s(StopIndex:end,i) = NaN * ones(length(x_s(:,i))-StopIndex+1,1);
    end
end
    
return