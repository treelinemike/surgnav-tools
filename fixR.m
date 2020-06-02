% make sure rotation matrix is orthogonal (i.e. adjust so det(R) = 1
function Rout = fixR(Rin)

err = abs(det(Rin)-1);
if( err > eps*10)
    ra = unitvec(Rin(:,1));
    rb = Rin(:,2);
    rb = unitvec(rb - dot(rb,ra)*ra);
    rc = cross(ra,rb);
    Rout = [ra, rb, rc];
    warning('Adjusting rotation matrix to correct determinant error (initially: %e; corrected: %e)\n', err, abs(det(R)-1));
else
    Rout = Rin;
end

end