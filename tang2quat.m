% convert so(3) tangent space representation to quaternion(s)
% will accept multiple tangent space vectors and return the same
% number of quaternions
function q = tang2quat(tang)
    if(size(tang,1) ~= 3)
        error('Tangent space coefficient matrix must have 3 rows!');
    end
    theta = vecnorm(tang,2,1);
    u = tang./theta;
    u( :, isnan(u(1,:))) = 0;     % if theta is zero we will need to fix some NaNs and make the corresponding unit vectors all zero
    q = [cos(theta/2); sin(theta/2).*u];  % this will always be a unit quaternion -> valid rotation
end