% extract the 3 coefficients of so(3) generators in tangent space
% corresponding to a quaternion

function tang_comp = quat2tang(q)
    R = quat2matrix( q );
    theta = acos((trace(R)-1)/2);
    ss = (theta/(2*sin(theta)))*(R-R');
    ss2 = logm( R );
    
    if(max(max(abs(ss2-ss))) > 1e-6)
        disp('logm() formulas inconsistent!');
        R
        ss
        ss2
        error('al;');
    end
    
    tang_comp = [-ss(2,3), ss(1,3), -ss(1,2)]';
end