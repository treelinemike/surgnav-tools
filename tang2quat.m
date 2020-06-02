% convert so(3) tangent space representation to quaternion
function q = tang2quat(tang)
    theta = norm(tang);
    u = tang/theta;
    q = [cos(theta/2); sin(theta/2)*[u(1); u(2); u(3)] ];  % this will always be a unit quaternion -> valid rotation
end