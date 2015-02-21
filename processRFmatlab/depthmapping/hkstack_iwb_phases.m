function [allstack] = hkstack_iwb_phases(SEIS,T0,DT,P,H,KAPPA,VP,W)
%[stack, stackvar] = hkstack_iwb(SEIS,T0,DT,P,H,KAPPA,VP)
%
% Stack the amplitudes of a set of receiver functions at predicted
% times of a Ps conversion and the first two multiples for different
% crustal thickness and Vp/Vs ratios, kind of following the method of Zhu and
% Kanamori (2000), JGR.  The only difference to their code is that
% their is no option for smoothing here.  You can apply that to your
% RFn data beforehand using a filter of your choice
%
% IN:
% SEIS = array of receiver function amplitudes [nt x nrf]
% T0 = start time for all receiver functions (s)
% DT = sample interval for all receiver functions (s)
% P = slowness for each RFn [nrf]
% H = Array of equally spaced depth values to investigate (km)
% KAPPA = Array of arbitrarily spaced Vp/Vs ratios to investigate 
% VP = (optional) crustal Vp (km/s) to use, default = 6.3 km/s
%

%--- hkstack.m --- 
% 
% Filename: hkstack.m
% Description: See Above
% Author: Lupei Zhu, March, 1997 at Caltech
% Maintainer: Iain Bailey 
% Created: Tue Feb 15 15:54:13 2011 (-0800)
% Version: 1
% Last-Updated: Sat Jul 23 09:05:28 2011 (-0700)
%           By: Iain Bailey
%     Update #: 208
% Compatibility: Matlab R2009a
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%-- Change Log:
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%-- Code:


% get dimensions
nh = numel(H);  % number of depths to investigate
nk = numel(KAPPA); % number of kappa values
nrf = numel(P); % number of rfns

% check the orientation of the seis array
if( size( SEIS,2 ) ~= nrf ),
  SEIS = SEIS.';
  if( size( SEIS,2 ) ~= nrf ),
    error(['One of the SEIS array dimensions [%i x %i] ',...
	   'should be the same as numel(P) [%i]'], ...
	  [size(SEIS,1), size(SEIS,2), nrf]);
    return
  end
end

% check the orientation of P
if( size( P, 1 ) > size( P, 2) ), P = P.'; end
%P = sort(P);%why sort the rayp? hh fixed at 2013-4-28

% amp correction for Ps
am_cor = 151.5478.*P.^2 + 3.2896.*P + 0.2618; 

% get all vs, single column
if( size( KAPPA, 1 ) < size( KAPPA, 2 ) ), KAPPA = KAPPA.'; end
vs = VP./KAPPA;

% get index of direct P
ti0 = round(-T0/DT)+1;

% %initialize stacks
%tstack = zeros(nk,nh,3);
%stack = zeros(nk,nh,3);
%stack2 = zeros(nk,nh,3);
%hh added
allstack = zeros(nk,nh,nrf);
%END
for i=1:nrf,
    eta_p = vslow( VP, P(i) ); % get vp vertical slowness
    eta_s = vslow( vs, P(i) ); % get vertical slowness for all vs

    % get times of Ps for all combinations of vs and H
    t1 = time2idx( tPs( H, eta_p, eta_s ), ti0, DT ); 

    % get times of PpPs + PsPp
    t2 =  time2idx( tPpPs( H, eta_p, eta_s ), ti0, DT ); 
   
    % get times of PsPs, NOTE: amplitude is negative 
    t3 =  time2idx( tPsPs( H, eta_s ), ti0, DT ); 

    tstack(:,:,1) = am_cor(i).*reshape( SEIS( t1, i), nk, nh );
    tstack(:,:,2) = am_cor(i).*reshape( SEIS( t2, i), nk, nh );
    tstack(:,:,3) = -1*am_cor(i).*reshape( SEIS( t3, i), nk, nh );

    % %add to existing stack
    %stack = stack + tstack; 
    %stack2 = stack2 + tstack.^2; % store for variance
    
    %% hh added 2013-4-28
    allstack(:,:,i) = W(1)* tstack(:,:,1) + W(2)* tstack(:,:,2) + W(3)* tstack(:,:,3);
    % END
    
    while i<nrf && P(i+1) == P(i), 
      % don't bother recalculating times for repeated values of slowness
      i = i+1;
      tstack(:,:,1) = am_cor(i).*reshape( SEIS( t1, i), nk, nh );
      tstack(:,:,2) = am_cor(i).*reshape( SEIS( t2, i), nk, nh );
      tstack(:,:,3) = -1*am_cor(i).*reshape( SEIS( t3, i), nk, nh );
      %stack = stack + tstack;
      %stack2 = stack2 + tstack.^2; 
      allstack(:,:,i) = W(1)* tstack(:,:,1) + W(2)* tstack(:,:,2) + W(3)* tstack(:,:,3);%hh added
    end
    
end

%%compute the mean and standard deviation of the stack
%stack = stack ./ nrf;  % divide by number
%stackvar = (stack2 - (stack).^2)./(nrf^2);
%% hh added
%allstackvar = var( allstack, 0, 3 );
allstack = mean( allstack, 3 );
%END
return

%------------------------------------------------------------
function ti = time2idx( times , ti0, dt )

ti = ti0 + round(times./dt); % get indices in single column
ti = reshape( ti, numel(ti), 1); % change so that x[(j-1)*nk+i] = x[i,j]

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%         Copyright (c) 1996-2006, L. Zhu (lupei@eas.slu.edu)
% 
% Permission to use, copy, modify, and distribute this package and supporting
% documentation for any purpose without fee is hereby granted, provided
% that the above copyright notice appear in all copies, that both that
% copyright notice and this permission notice appear in supporting
% documentation.
% 
% In case that you modify any codes in this package, you have to
% change the name of the modified code. You are welcome to send me a note
% about your modification and any suggestion.
% 
% In case that you redistribute this package to others, please send me
% the contacting info (email addr. preferred) so that future updates
% of this package can be sent to them.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% hkstack.m ends here
