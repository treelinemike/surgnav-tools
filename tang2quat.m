function q = tang2quat(tang)

    R = expm([0 -tang(3) tang(2); tang(3) 0 -tang(1); -tang(2) tang(1) 0]);
    
    % fix rotation matrix if determinant is too large 
    err = abs(det(R)-1);
    if( err > eps*10)
        ra = unitvec(R(:,1));
        rb = R(:,2);
        rb = unitvec(rb - dot(rb,ra)*ra);
        rc = cross(ra,rb);
        R = [ra, rb, rc];
        warning('Adjusting rotation matrix to correct determinant error (initially: %e; corrected: %e)\n', err, abs(det(R)-1));
    end
    
    % assign output
    q = matrix2quat(R);
    
end