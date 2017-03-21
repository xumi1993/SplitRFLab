function [PS_RFdepth, EndIndex, x_s, x_p] = PSRF2depth(datar, rayp, YAxisRange, sampling, shift,velmod)

RFlength = size(datar,1); EV_num = size(datar, 2);

%% Model information
Velocity1D=velmod;
VelocityModel = load(Velocity1D,'-ascii');


% Depths
%--------------------------------------------------------------------------
Depths = VelocityModel(:,1);
% Velocities
%--------------------------------------------------------------------------
Vp = VelocityModel(:,3);
Vs = VelocityModel(:,2);
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
    
x_s(:,i) = cumsum((dz./R) ./ sqrt((1./(rayp(i)^2.* (R./Vs).^-2)) - 1));%Pds piercing distance from station in rad
raylength_s(:,i) = (dz.*R) ./  (sqrt(((R./Vs).^2) - (rayp(i)^2)).* Vs);
x_p(:,i) = cumsum((dz./R) ./ sqrt((1./(rayp(i)^2.* (R./Vp).^-2)) - 1));%P piercing distance from station in rad
raylength_p(:,i) = (dz.*R) ./  (sqrt(((R./Vp).^2) - (rayp(i)^2)).* Vp);

% Calculate Pds travel time
%----------------------------------------------------------------------
Tpds(:,i) = cumsum((sqrt((R./Vs).^2 - rayp(i)^2) - sqrt((R./Vp).^2 - rayp(i)^2)) .* (dz./R));%the travel time versus depth in columns for all RFs

end

%% Convert the time axis to the depth axis
TimeAxis=((0:1:RFlength-1)*sampling-shift)';
PS_RFdepth = zeros(length(Depths),EV_num);
EndIndex = zeros(EV_num,1);
%Depthaxis =(0:1:700)';
%PS_RFdepth = zeros(701,EV_num);
 
for i = 1:EV_num
    TempTpds = Tpds(:,i);
StopIndex = find(imag(TempTpds),1);
if ~isempty(StopIndex)
    EndIndex(i) = StopIndex - 1;
else
    EndIndex(i) = length(Depths);
end

%PS_RFdepth(:,i) = interp1(Timeaxis,datar(:,i),Tpds(1:701,i));
   if isempty(StopIndex)
        DepthAxis = interp1(TempTpds,Depths,TimeAxis);
    else
        DepthAxis = interp1(TempTpds(1:(StopIndex-1)),Depths(1:(StopIndex-1)),TimeAxis);
   end   
    PS_RFTempAmps = datar(:,i);    
    ValueIndices = find (~isnan(DepthAxis));   
    
    
    %TPsdepth(i) = interp1(TimeAxis(ValueIndices),DepthAxis(ValueIndices),Tpds(29,i));
    %TPpPsdepth(i) = interp1(TimeAxis(ValueIndices),DepthAxis(ValueIndices),Tpppds(29,i));
    %TPsPsdepth(i) = interp1(TimeAxis(ValueIndices),DepthAxis(ValueIndices),Tpspds(29,i));
    
    if isempty(ValueIndices)   
        PS_RFAmps = TempTpds * NaN;        
    elseif max(ValueIndices) > length(PS_RFTempAmps)
        PS_RFAmps = TempTpds * NaN;  
        
    else
        PS_RFAmps = interp1(DepthAxis(ValueIndices),PS_RFTempAmps(ValueIndices),YAxisRange);
        PS_RFAmps = colvector(PS_RFAmps);
        PS_RFdepth(:,i) = PS_RFAmps/max(PS_RFAmps);        
    end    
    
end

return

    
        
        
            
            


    
        
        
    
    