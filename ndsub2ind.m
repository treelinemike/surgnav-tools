% subscripts to index in n-dimensions
% without needing to specify dimensionality via separate arguments
% sub = matrix with #col = #dim; #row = #points to evaluate
% ind = vector length = (#row of sub) with indices of each query point
%
% Mike Kokko
% May 9, 2020
%
function ind = ndsub2ind(dimLengths,sub)
dimSizes = [1 cumprod(dimLengths(1:end-1))];
ind = zeros(1,length(dimLengths));

for pointNum = 1:size(sub,1)
    pointIdx = 1;
    for dimIdx = 1:length(dimLengths)
        pointIdx = pointIdx + dimSizes(dimIdx)*(sub(pointNum,dimIdx)-1);
    end
    ind(pointNum) = pointIdx;
end
end