% Take the complex conjugate of a quaternion
% This essentially reverses the sign of each imaginary part
% maintaining the sign of the real part
%
% Ref: Kuipers2002: Quaternions and Rotation Sequences: A Primer with Applications to Orbits, Aerospace and Virtual Reality
% see pg 110 (ch. 5: Quaternion Algebra) 
function q = quatconj(a)

% q = a;
% for imagIdx = 1:3
%     q(imagIdx+1) = -1*q(imagIdx+1);
% end

q = a .* [1 -1 -1 -1]';

end