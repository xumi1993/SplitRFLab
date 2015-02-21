function X = colvector(x);
%COLVECTOR Force vector to be a column vector
%
%    COLVECTOR(x) forces the vector x to be a column vector.  x MUST be a
%    1xn or nx1 vector.
%
%    Kevin C. Eagar
%    January 31, 2008
%    Last Updated: 01/31/2008

if ~isvector(x)
    error('Input must be a vector.')
end
if size(x,2) > 1
    X = x';
else
    X = x;
end