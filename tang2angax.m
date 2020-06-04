% tangent space so(3) coefficients -> [angle u_x u_y u_z]'
function angax = tang2angax(tang)
if(norm(tang) < 10*eps)
    u = [0 0 0]';
else
    u = unitvec(tang);
end

angax = [ norm(tang); u(1); u(2); u(3)];