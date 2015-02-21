function [PS_RFdepth, EndIndex]=PSRF_time2depth(Tpds,datar, YAxisRange, sampling, shift)

Depths = YAxisRange; EV_num=size(Tpds,2); RFlength=size(datar,1);

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