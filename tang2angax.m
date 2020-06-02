% tangent space so(3) coefficients -> [angle u_x u_y u_z]'
function angax = tang2angax(tang)
u = unitvec(tang);
angax = [ norm(tang); u(1); u(2); u(3)];