% rotation matrix to quaternon
function q = matrix2quat(R)

% make sure input is a rotation matrix -> SO(3)
if((size(R,1) ~= 3) || (size(R,2) ~= 3))
    error('Input matrix must be 3 x 3');
elseif( abs(det(R)-1) > eps*100 )
    error('Input matrix must have determinant 1.0 -> SO(3)');
elseif( norm(eye(3)-R'*R,'fro') > eps*100 )  % example from MATLAB... A' = inv(A) if A is orthogonal;
    error('Input matrix must be orthogonal -> SO(3)');
end

% ensure that R is orthogonal 
R = fixR(R);

q = zeros(4,1);
q(1) = sqrt(1+trace(R))/2;
q(2) = (R(3,2)-R(2,3))/(4*q(1));
q(3) = (R(1,3)-R(3,1))/(4*q(1));
q(4) = (R(2,1)-R(1,2))/(4*q(1));

end