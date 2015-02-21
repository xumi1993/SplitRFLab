function [der] = derive(sig,delta)

a = size(sig);
nsig = a(2);
npoint = a(1);
for j=1:nsig
  der(1,j) = 0.0;
  der(npoint,j) = 0.0;
  for k = 2:npoint-1 
    der(k,j) = (sig(k+1,j)-sig(k-1,j))/(2*delta);
  end
end

