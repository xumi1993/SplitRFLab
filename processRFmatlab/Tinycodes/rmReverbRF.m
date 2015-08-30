function newtr = rmReverbRF(rf, shift, dt)
RFlength = length(rf);
timeaxis = -shift:dt:(RFlength-1)*dt-shift;
% samp_P = shift/dt+1;
% samp_after = samp_P+40/dt;
% rf = rf(samp_P:samp_after);
% timeaxis = timeaxis(samp_P:samp_after);
ac = xcorr(rf);
ac = ac((length(ac)-1)/2+1:end);
ac = ac/max(ac);
[~, minx] = extrema(ac,'min');
r0 = ac(minx(1));
rmflt = zeros(length(rf),1);
rmflt(1) = 1;
rmflt(minx(1)) = -r0;
newtr = ifft(fft(rf)./fft(rmflt));
plot(abs(fft(rmflt)))
% newtr = conv(rf,rmflt);
% newtr = newtr(1:RFlength);
h1 = subplot(1,2,1);
plot(timeaxis,newtr);
h2 = subplot(1,2,2);
plot(timeaxis,rf);
set(h1,'xlim',[0 30]);
set(h2,'xlim',[0 30]);
return