function tang = angax2tang(angax)

if(norm(angax(2:4)) < 10*eps)
    u = [0 0 0]';
else
    u = unitvec([angax(2); angax(3); angax(4)]);
end
tang = angax(1)*u;

end