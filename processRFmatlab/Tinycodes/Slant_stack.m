function amp = Slant_stack(seis,timeaxis,rayp_range, tau_range,ref_dis,dis)


EV_num = size(seis,2);
amp = zeros(length(rayp_range),length(tau_range));
tmp = zeros(EV_num,length(tau_range));

for j = 1:length(rayp_range)
    for i = 1:EV_num
        seis(:,i)=seis(:,i)./max(abs(seis(:,i)));
        tps = tau_range - rayp_range(j) * (dis(i) - ref_dis);
        tmp(i,:) = interp1(timeaxis',seis(:,i),tps')';
    end
    nanidx = find(isnan(tmp));
    tmp(nanidx) = 0;
    tmp = mean(tmp);
    amp(j,:) = tmp;
end


