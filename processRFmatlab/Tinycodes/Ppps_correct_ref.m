function [Newdatar, EndIndex, x_s, x_p] = Ppps_correct_ref(datar, rayp, raypref, YAxisRange, sampling, shift)

RFlength = size(datar,1); EV_num = size(datar, 2);
%% Model information
Velocity1D='/Users/xumj/Documents/MATLAB/ccp/VEL_models/IASP91.vel';
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
    Tpppds=zeros(length(YAxisRange),EV_num);
for i = 1:EV_num
    
x_s(:,i) = cumsum((dz./R) ./ sqrt((1./(rayp(i)^2.* (R./Vs).^-2)) - 1));%Pds piercing distance from station in rad
raylength_s(:,i) = (dz.*R) ./  (sqrt(((R./Vs).^2) - (rayp(i)^2)).* Vs);
x_p(:,i) = cumsum((dz./R) ./ sqrt((1./(rayp(i)^2.* (R./Vp).^-2)) - 1));%P piercing distance from station in rad
raylength_p(:,i) = (dz.*R) ./  (sqrt(((R./Vp).^2) - (rayp(i)^2)).* Vp);

% Calculate Pppds travel time
%----------------------------------------------------------------------
Tpppds(:,i) = cumsum((sqrt((R./Vs).^2 - rayp(i)^2) + sqrt((R./Vp).^2 - rayp(i)^2)) .* (dz./R));

end

% Tpppds_ref = cumsum((sqrt((R./Vs).^2 - (rad2deg(raypref))^2) + sqrt((R./Vp).^2 - (rad2deg(raypref))^2)) .* (dz./R));%the travel time for referred rayp 

Tpppds_ref = cumsum((sqrt((R./Vs).^2 - raypref^2) + sqrt((R./Vp).^2 - (raypref)^2)) .* (dz./R));
%% Adjust the travel time by compressing/stretching the time scale
Newdatar=zeros(RFlength,EV_num); EndIndex = zeros(EV_num, 1);
for i = 1:EV_num
    disp(['moveout ' num2str(i) 'th of' num2str(EV_num) '----------'])
TempTpppds = Tpppds(:,i);
StopIndex = find(imag(TempTpppds),1);
if isempty(StopIndex)
    StopIndex = length(Depths) + 1;
end
EndIndex(i) = StopIndex - 1;
Newaxis(1:(shift/sampling+1)) = -shift:sampling:0;
    for j = (shift/sampling)+2:RFlength
        Refaxis = (j-1)*sampling - shift;        
         index = find(Refaxis <= Tpppds((1:StopIndex-1),i),1,'first');        
         if isempty(index)
            break;end
         Ratio = (Tpppds_ref(index) - Tpppds_ref(index-1))/(Tpppds(index,i) - Tpppds(index-1,i));
         Newaxis(j) = Tpppds_ref(index-1) + (Refaxis - Tpppds(index-1,i))*Ratio;               
    end      
    
    if j < RFlength        
    j=j-1;
    end    
    %New RF generated
    Tempdata = interp1(real(Newaxis),datar(1:j,i)',(0:1:RFlength-1)*sampling-shift);
    endIndice = find(isnan(Tempdata),1,'first');
    
     if isempty(endIndice)
        New_data = Tempdata;
    else
        New_data = [Tempdata(1:endIndice-1)';datar(j+1:end,i)];
    end
   
    %adjust to the length equal to RFlength:    
        if length(New_data) < RFlength
           Newdatar(:,i)=[New_data;zeros(RFlength - length(New_data),1)];
        else
           Newdatar(:,i)=New_data(1:RFlength);
        end
     %%Normalization
     %Newdatar(:,i) = Newdatar(:,i)/max(Newdatar(:,i));
    Newaxis = []; New_data = [];
end

return

    
        
        
            
            


    
        
        
    
    