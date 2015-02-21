function [phiSC, dtSC, phiEV, dtEV, inipol, Emap, correctFastSlow, corrected_QT, Eresult] =...
    splitSilverChan(Q, T,  bazi, pickwin, sampling, maxtime, option, inipoloption)
% shear wave splitting using the Silver & Chan (1991) method
% "Minimising the energy on transverse component". The original Q- and T-
% components are rotated to test coordinate systems and then time-shifted
% relative to one another. The shifted seismograms are rotated back to the
% original Q-T-system to evalute the Energy on the (new) Transverse
% component. If the test system is corresponds to the anisotropic Fast-Slow
% system, this erngery is minimal.
%
% INPUTS:
%    Q,T      = Sv and Sh seismogram components in Ray system as column vectors
%    bazi     = backazimuth
%    pickwin  = indices to pick, Q and T may be longer than picked window.
%               Here, the indices to the selected window are given
%    sampling = sampling of seismograms records (in seconds)
%    maxtime  = maximum search time (in seconds)
%    option   = splitting method to be used
%    inipoloption = for EV method: using 'fixed' polarisation (from
%                   backazimuth or 'estimated' from wave form
%
% OUTPUTS:
%    Ematrix = correlation map of test directions
%    phiSC   = best estimated fast axis (SC-method)
%    dtSC    = best estimated delay time (SC-method)
%    phiEV   = best estimated fast axis (EV-method)
%    dtEV    = best estimated delay time (EV-method)
%    inipol  = initial polarisation of wave
%    Emap    = matrix representing the Energy Map (:,:,1) and Eigenvalue Map (:,:,2)    
%    correctFastSlow = 2xN vector of corrected components for the method "option":
%                      first column:  Fast
%                      second column: Slow
%    corrected_QT    = 2xN vector of corrected components for the method "option":
%                      first column:  corrected Q
%                      second column: corrected T
%    Eresult         = absulute Value in Emap, corresponding to the best
%                      inversion (e.g. for the SC method min(Energy map))
%
% Andreas Wüstefeld 12.03.06



f        = 2;%accuracy factor; 1==using all possibilities, which is slowest; only values: 2^n


%searching for fast axis by rotating clock wise
% in L-Q-T system (right handed; L up, Q towards earthquake and T 
% perpendicular to both) about ray axis (L, == quasi veritcal, along P-path)
% in this local coordinate system the corresponding axis in are:
%
%                Q == x-axes           T ^
%                T == y-axis             |
%                L == uppointing         |     Q
%                                        o----->
%               
%starting at "9 o'clock" (=-90°); going to "12"; ending at "3" (=+90°)
phi_test = ((-90:1*f:90))/180*pi;
phi_test = phi_test(1:end-1);

dt_test  = fix(0:f*1:maxtime/sampling);      % test delay times (in samples)


M(1,1,:) =   cos(phi_test);      M(1,2,:) =  -sin(phi_test);
M(2,1,:) =   sin(phi_test);      M(2,2,:) =   cos(phi_test);


%initilize Energy matrix for speed:
Ematrix = zeros(length(phi_test), length(dt_test));
l1=zeros(size(Ematrix));
l2=zeros(size(Ematrix));
eigvec = zeros([size(Ematrix) 2]);

%% Rotation and shift
tic
for p=1:length(phi_test)
    FS_Test = M(:,:,p) * [Q, T]';% Test fast/slow direction
    for t=1:length(dt_test)
        shift = dt_test(t); % shift index
        tmpSlow = FS_Test(2,pickwin+shift);
        tmpFast = FS_Test(1,pickwin);

        % rotate back to Radial-Transversal-system
        % M' == inv(M), but faster :-)
        corrected_QT = M(:,:,p)' * [ tmpFast; tmpSlow];

        % Energy on transverse component
        % E = sum(corrected_Transv^2);
        Ematrix(p,t) = corrected_QT(2,:)*corrected_QT(2,:)';

        % Eigenvalue calculation for non-*KS waves
        % vec is in Q-T coordinates, with first row corresponding to Q,
        % second row to T direction
        [vec, lambda]  = eig(cov(corrected_QT(1,:), corrected_QT(2,:)));
        [l1(p,t), ind] = max(diag(lambda));
        l2(p,t)        = min(diag(lambda));
        eigvec(p,t,:)  = vec(:,ind); 
    end
end



%% OPTIONS:
[indexPhiSC,indexDtSC]   = find(Ematrix==min(Ematrix(:)), 1);
[tmp, ind(1)]            = max(l1(:));
[tmp, ind(2)]            = min(l2(:));
[tmp, ind(3)]            = max(l1(:)./l2(:));
[tmp, ind(4)]            = min(l1(:).*l2(:));

phi_test_min = (phi_test(indexPhiSC)/ pi * 180);  % fast axis in Q-T-system
phiSC  = mod((phi_test_min  + bazi), 180);        % fast axis in E-N-system
shift  = dt_test(indexDtSC); % samples
dtSC   = shift * sampling; % seconds
  
if phiSC>90
    phiSC = phiSC-180; %put in [-90:90]
end

switch option
    %Get results for Eigenvalue methods and minimum Energy method
    % indexPhi and indexDt contain the selected method, for which
    % the fast and slow components are later recalulated
    
    case 'Minimum Energy'
        %using SC values for rotation of matrix
        indexPhi = indexPhiSC;
        indexDt  = indexDtSC;
        %% using min(lambda2) as default EV method
        [tmp, ind]               = min(l2(:));
        [indexPhiEV, indexDtEV]  = ind2sub(size(l2), ind);
               
        Emap = cat(3,Ematrix,  l2);%stack as another layer of the matrix (==3rd dimension)

    
    case 'Eigenvalue: max(lambda1 / lambda2)'
        [tmp, ind]                = max(l1(:)./l2(:));
        [indexPhiEV, indexDtEV]   = ind2sub(size(l2), ind);
        indexPhi = indexPhiEV;
        indexDt  = indexDtEV;
       
        Emap = cat(3,Ematrix,  -(l1./l2));%stack as another layer of the matrix (==3rd dimension)
        
    case 'Eigenvalue: min(lambda2)'
        [tmp, ind]               = min(l2(:));
        [indexPhiEV, indexDtEV]  = ind2sub(size(l2), ind);
        indexPhi = indexPhiEV;
        indexDt  = indexDtEV;
         
        Emap = cat(3,Ematrix,  l2);%stack as another layer of the matrix (==3rd dimension)


    case 'Eigenvalue: max(lambda1)'
        [tmp, ind]               = max(l1(:));
        [indexPhiEV, indexDtEV]  = ind2sub(size(l2), ind);
        indexPhi = indexPhiEV;
        indexDt  = indexDtEV;
    
        Emap = cat(3,Ematrix,  -l1);%stack as another layer of the matrix (==3rd dimension)


    case 'Eigenvalue: min(lambda1 * lambda2)'
        [tmp, ind]               = min(l1(:).*l2(:));
        [indexPhiEV, indexDtEV]   = ind2sub(size(l2), ind);
        indexPhi = indexPhiEV;
        indexDt  = indexDtEV;
     
        Emap = cat(3,Ematrix,  l1.*l2);
end


eigen = squeeze (eigvec(indexPhiEV,indexDtEV,:));
% Polarisation in respect to backazimuth, counting ccw 
% (therefor the "-" sign) in Q-T system;
% for bazi=0 Q points towards north (the "Yaxis"): we musn't use   90-atan2...
inipolQT   = -atan2(eigen(2), eigen(1))/ pi * 180 ;  
inipol     = mod(bazi+inipolQT , 360);                 % polarisation in ENZ system


phi_test_min = (phi_test(indexPhiEV)/ pi * 180); % fast axis in "backazimuthal" Q-T-system
if strcmp(inipoloption, 'fixed')
    phiEV  = mod((bazi + phi_test_min),  180);       % fast axis in E-N-system
else %'estimated'
     phiEV  = mod((inipol + phi_test_min),  180);       % fast axis in E-N-system
end

shift  = dt_test(indexDtEV); % samples
dtEV   = shift * sampling;   % seconds

if phiEV>90
    phiEV = phiEV-180; %put in -90:90
end


%%
Eresult(1) = Emap(indexPhiSC, indexDtSC, 1);
Eresult(2) = Emap(indexPhiEV, indexDtEV, 2);
Emap(:,:,1) = circshift(Emap(:,:,1), floor(mod(bazi, 180)/f) );
if strcmp(inipoloption, 'fixed')
    Emap(:,:,2) = circshift(Emap(:,:,2), floor(mod(bazi, 180)/f) );
else %'estimated'
    Emap(:,:,2) = circshift(Emap(:,:,2), floor(mod(inipol, 180)/f) );
end


%% seismograms in fast/slow directions
shift = dt_test(indexDt);

FS_Test  = M(:,:,indexPhi) * [Q, T]' ;   % extended window
tmpFast  = FS_Test(1,pickwin);
tmpSlow  = FS_Test(2,pickwin+shift);

correctFastSlow(:,1)  = tmpFast; %fast component in pick window
correctFastSlow(:,2)  = tmpSlow; %slow component in shifted pick window


corrected_QT = M(:,:,indexPhi)' * [ tmpFast; tmpSlow];
corrected_QT = corrected_QT';


% figure(98)
% L=1:length(corrected_QT);
% plot(L,corrected_QT(:,1),'c', L,corrected_QT(:,2),'m')