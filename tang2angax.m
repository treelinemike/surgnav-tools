% convert tangent space so(3) coefficients to [angle u_x u_y u_z]'
function angax = tang2angax(tang)

% basic error checking
if(size(tang,1) ~= 3)
    error('Tangential representation of rotation must be a 3xN matrix.');
end

% extract unit vector, using care to avoid division by zero and replacing
% any very small or zero vectors with the zero vector
u = zeros(size(tang));
zeroVecMask = vecnorm(tang,2,1) < 10*eps; 
u(:,zeroVecMask) = 0;
u(:,~zeroVecMask) = unitvec(tang(:,~zeroVecMask));

% assemble angle/axis representation
angax = [ vecnorm(tang,2,1); u ];

end