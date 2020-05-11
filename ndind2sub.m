% index to subscripts in n-dimensions
% without needing to specifcy dimensionality explicitly for output args
%
% Mike Kokko
% May 9, 2020
%
function sub = ndind2sub(dimLengths,ind)
dimSizes = [1 cumprod(dimLengths(1:end-1))];
sub = zeros(1,length(dimLengths));
for dimIdx = length(dimLengths):-1:1
    thisIdx = ceil( ind / dimSizes(dimIdx) );
    sub(dimIdx) = thisIdx;
    ind = ind - (thisIdx-1)*dimSizes(dimIdx);
end
end
