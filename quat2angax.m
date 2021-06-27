function angax = quat2angax(q)

% make sure q_in is the correct length and shape
if (numel(q_in) == 4)
    q_in = reshape(q_in,4,1);
else
    error('Quaternion must have 4 elements.');
end

% normalize quaternion (it should be very close to a unit quaternion anyway...)
q_in = q_in/norm(q_in);

angax = zeros(4,1);
halftheta = acos(q(1));
if(halftheta < 10*eps)
    angax = [0 0 0 0]';
else
    angax(1) = 2*halftheta;
    angax(2:4) = (1/sin(halftheta))*q(2:4);
end
end