function isOK = checkConditions(hdr,opt)

% Check conditions for processing, edit this based on what you want
%
% isOK = checkConditions(hdr,opt)
%
% IN:
% hdr = header info read in by sachdr.m
% opt = options...
%    opt.MINZ, opt.MAXZ = min and max depths
%    opt.DELMIN, opt.DELMAX = min and max event station separations
%    opt.MAGMIN, opt.MAGMAX = min and max magnitudes
%
% OUT:
% isOK = true if passes tests, false if not

isOK = true;
if ( hdr.event.evdp < opt.MINZ | hdr.event.evdp > opt.MAXZ ),
  isOK = false;
  fprintf('\tBad depth, z = %f \n', hdr.event.evdp )
end

if( hdr.evsta.gcarc < opt.DELMIN || hdr.evsta.gcarc > opt.DELMAX ),
  isOK = false;
  fprintf('\tBad GC arc, Del = %f \n', hdr.evsta.gcarc )
end

if( hdr.event.mag < opt.MAGMIN || hdr.event.mag > opt.MAGMAX ),
  isOK = false;
  fprintf('\tBad Mag, M = %f \n', hdr.event.mag )
end


return

%----------------------------------------------------------------------
