function q = angax2quat(angax)
theta = angax(1);    
u = unitvec(angax(2:4)); % should already be a unit vector
q = [cos(theta/2); sin(theta/2)*[u(1); u(2); u(3)]];
end
