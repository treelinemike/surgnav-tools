function q = angax2quat(angax)
theta = angax(1);
if(norm(angax(2:4)) < 10*eps)
    u = [0 0 0]';
else
    u = unitvec(angax(2:4)); % should already be a unit vector
end
q = [cos(theta/2); sin(theta/2)*[u(1); u(2); u(3)]];
end
