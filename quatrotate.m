% perform quaternion rotation
% essentially using angle (theta) and axis (u, a unit vector) of rotation
% q =     q0     +     q123
% q = cos(theta/2) + sin(theta/2)*u
%
% Ref: Kuipers2002: Quaternions and Rotation Sequences: A Primer with Applications to Orbits, Aerospace and Virtual Reality
% see eq 5.9 on pg 125 (ch. 5: Quaternion Algebra) 
%
% note: MATLAB includes a similar function in the aerospace toolbox, but
% this is not part of the Dartmouth site license
function v_out = quatrotate(q_in,v_in)

% make sure q_in and v_in are the correct length and shape
if (numel(q_in) == 4)
    q_in = reshape(q_in,4,1);
else
    error('Quaternion must have 4 elements.');
end
if (numel(v_in) == 3)
    v_in_size = size(v_in);
    v_in = reshape(v_in,3,1);
else
    error('Vector to rotate must have 3 elements.');
end

% normalize quaternion (it should be very close to a unit quaternion anyway...)
q_in = q_in/norm(q_in);

% extract scalar and vector parts of quaternion
q0   = q_in(1);   % real (scalar) part of quaternion
q123 = q_in(2:4); % imaginary (vector) part of quaternion
v_out = (q0^2-norm(q123)^2)*v_in + 2*dot(q123,v_in)*q123 + 2*q0*cross(q123,v_in);

% reshape output vector according to format of input vector (col vs. row)
v_out = reshape(v_out,v_in_size);

% alternatively, an equivalent (albeit more computationally expensive) method
% is to rotate v_in using point rotation directly: v_out = q * v_in * conj(q)
% q_out = quatmult(q_in,quatmult([0; v_in],quatconj(q_in)))
% v_out = q_out(2:4)

end