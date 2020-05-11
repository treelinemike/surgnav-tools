% from Guillaume on Matlab Centeral Answers:
% https://www.mathworks.com/matlabcentral/answers/332718-can-i-store-multiple-outputs-of-a-function-into-a-cell
% note: output is serialized, but not entirely consistent with serialzied
% output from [XX,YY] = meshgrid(xvec,yvec)... need to transpose via XXT = XX'; XXT(:)
% to get same results...
% meshgrid() and ndgrid() use different conventions:
% https://www.mathworks.com/matlabcentral/answers/99720-what-is-the-difference-between-the-ndgrid-and-meshgrid-functions-in-matlab
function p = cartprod(c)
%returns the cartesian products of the vectors contained in cell array v
p = cell(size(c));
[p{:}] = ndgrid(c{:});
p = cell2mat(cellfun(@(x) x(:), p, 'UniformOutput', false));
end