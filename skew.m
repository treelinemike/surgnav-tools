% produce skew symmetric matrix
% this likely duplicates the function in the MATLAB robotics toolbox
function X = skew(x)

    % make sure we have a 3-element vector
    if(numel(x)~=3)
        error('Input must be a 3-element vector');
    end

    % initialize to all zeros
    X = zeros(3,3);

    % add the upper triangular portion
    X(1,2) = -x(3);
    X(1,3) = x(2);
    X(2,3) = -x(1);

    % add the lower triangular portion
    X = X - X';

end