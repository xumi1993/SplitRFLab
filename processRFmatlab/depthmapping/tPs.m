function result = tPs( depth, eta_p, eta_s )
% tPs( depth, eta_p, eta_s )
% time taken for Ps conversion
result = ( eta_s - eta_p )*depth;
