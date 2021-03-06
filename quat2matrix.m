% compute rotation matrix from quaternion
%
% this matrix applied as R*v rotates column vector v by quaternion q in a in a fixed frame
% use R'*v to rotate coordinate frame by quaternion q, leaving vector column vector v fixed
%
% can operate on row vectors as well
% consider taking the transpose of both sides of: x = A*b -> (x)' = (A*b)' -> x' = b'*A'
% to rotate a row vector w use: w*R'; likewise to express row vector w in a rotated frame use: w*R
%
% Ref: Kuipers2002: Quaternions and Rotation Sequences: A Primer with Applications to Orbits, Aerospace and Virtual Reality
% see pg 126 (ch. 5: Quaternion Algebra)
function R = quat2matrix(q)

% make sure q_in is the correct length and shape
if (numel(q) == 4)
    q = reshape(q,4,1);
else
    error('Quaternion must have 4 elements.');
end

% normalize quaternion (it should be very close to a unit quaternion anyway...)
q = q/norm(q);

R = [ 2*q(1)^2-1+2*q(2)^2,     2*q(2)*q(3)-2*q(1)*q(4), 2*q(2)*q(4)+2*q(1)*q(3);
      2*q(2)*q(3)+2*q(1)*q(4), 2*q(1)^2-1+2*q(3)^2,     2*q(3)*q(4)-2*q(1)*q(2);
      2*q(2)*q(4)-2*q(1)*q(3), 2*q(3)*q(4)+2*q(1)*q(2), 2*q(1)^2-1+2*q(4)^2      ];

% ensure that R is orthogonal 
% R = fixR(R);

end