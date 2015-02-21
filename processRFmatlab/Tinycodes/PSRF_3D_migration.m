function [TimeCorrections, newTpds]=PSRF_3D_migration(pplat_s, pplon_s, pplat_p, pplon_p, raylength_s, raylength_p, Tpds, YAxisRange, model_path)

RFdepth=size(raylength_p,1);  EV_num=size(raylength_p,2);



% Load and setup the 3D tomography model
%--------------------------------------------------------------------------
load(model_path)
TDepths(:,1) = model_3D.dep(1,1,:);
TLons(:,1) = model_3D.lon(:,1,1);
TLats(:,1) = model_3D.lat(1,:,1);


% Load and setup the 1D velocity model
%--------------------------------------------------------------------------
Velocity1D='/Users/xumj/Documents/MATLAB/ccp/VEL_models/IASP91.vel';
VelocityModel = load(Velocity1D,'-ascii');
VDepths = VelocityModel(:,1);
Vp = VelocityModel(:,2);
Vs = VelocityModel(:,3);
NewVp(1,1,:) = interp1(VDepths,Vp,TDepths);
NewVs(1,1,:) = interp1(VDepths,Vs,TDepths);
NewVp = repmat(NewVp,[length(TLons) length(TLats) 1]);
NewVs = repmat(NewVs,[length(TLons) length(TLats) 1]);
dModelP = (model_3D.Vp - NewVp)./NewVp;
dModelS = (model_3D.Vs - NewVs)./NewVs;


CVp = interp1(VDepths,Vp,YAxisRange);
CVs = interp1(VDepths,Vs,YAxisRange);

% Compute the travel time perturbations in each ray tracing matrix
%--------------------------------------------------------------------------

% 
%     xi = pplat_p; yi = pplon_p; zi = repmat(YAxisRange',1,EV_num);
%     [StopIndex,stopEV] = find(isnan(xi),1);    
%     if ~isempty(StopIndex)
%         for i=1:length(StopEV)
%             xi = xi(1:StopIndex-1,StopEV(i)); yi = yi(1:StopIndex-1,StopEV(i)); zi = zi(1:StopIndex-1,StopEV(i));
%             dvp = interp3(model_3D.lat,model_3D.lon,model_3D.dep,dModelP,xi,yi,zi);
%             dvp = [dvp;(NaN * ones(RFdepth-StopIndex+1,EV_num))];
%         end
%         
%     else
%         dvp = interp3(model_3D.lat,model_3D.lon,model_3D.dep,dModelP,xi,yi,zi);
%     end
%     
%     
%     xi = pplat_s; yi = pplon_s; 
%     StopIndex = find(isnan(xi),1);
%     if ~isempty(StopIndex)
%         xi = xi(1:StopIndex-1,:); yi = yi(1:StopIndex-1,:); zi = zi(1:StopIndex-1,:);
%         dvs = interp3(model_3D.lat,model_3D.lon,model_3D.dep,dModelS,xi,yi,zi);
%         dvs = [dvs;(NaN * ones(RFdepth-StopIndex+1,EV_num))];
%     else
%         for m=1:RFdepth
%         dvs = interp3(model_3D.lat,model_3D.lon,model_3D.dep,dModelS,xi,yi,zi);
%         end
%     end
%     dvp=dvp'; dvs=dvs';
%     dls = raylength_s'; dlp = raylength_p';
%     Temp = (dls./(CVs.*(1+dvs)) - dls./CVs) - (dlp./(CVp.*(1+dvp)) - dlp./CVp);
%     Temp(isnan(Temp)) = 0;
%     TimeCorrections(:,i) = cumsum(Temp);     
TimeCorrections=zeros(RFdepth,EV_num);

for i=1:EV_num
    disp(['event NO.' num2str(i) '/' num2str(EV_num)])
    xi = pplat_p(:,i); yi = pplon_p(:,i); zi = YAxisRange';
    StopIndex = find(isnan(xi),1);
    if ~isempty(StopIndex)
        xi = xi(1:StopIndex-1); yi = yi(1:StopIndex-1); zi = zi(1:StopIndex-1);
        dvp = interp3(model_3D.lat,model_3D.lon,model_3D.dep,dModelP,xi,yi,zi);
        dvp = [dvp;(NaN * ones(RFdepth-StopIndex+1,1))];
        
    else
        dvp = interp3(model_3D.lat,model_3D.lon,model_3D.dep,dModelP,xi,yi,zi);
%         for m=1:RFdepth
%         dvp(m) = interp3(model_3D.lat,model_3D.lon,model_3D.dep,dModelP,xi(m),yi(m),zi(m));
%         end
    end
    
    
    xi = pplat_s(:,i); yi = pplon_s(:,i); zi = YAxisRange';
    StopIndex = find(isnan(xi),1);
    if ~isempty(StopIndex)
        xi = xi(1:StopIndex-1); yi = yi(1:StopIndex-1); zi = zi(1:StopIndex-1);
        dvs = interp3(model_3D.lat,model_3D.lon,model_3D.dep,dModelS,xi,yi,zi);
        dvs = [dvs;(NaN * ones(RFdepth-StopIndex+1,1))];
    else
        for m=1:RFdepth
        dvs = interp3(model_3D.lat,model_3D.lon,model_3D.dep,dModelS,xi,yi,zi);
        end
    end
    dvp=dvp'; dvs=dvs';
    dls = raylength_s(:,i)'; dlp = raylength_p(:,i)';
    Temp = (dls./(CVs.*(1+dvs)) - dls./CVs) - (dlp./(CVp.*(1+dvp)) - dlp./CVp);
    Temp(isnan(Temp)) = 0;
    TimeCorrections(:,i) = cumsum(Temp);        
end

newTpds = TimeCorrections + Tpds;
    
return