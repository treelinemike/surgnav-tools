% extract the 3 coefficients of so(3) generators in tangent space
% corresponding to a quaternion
%
% quaternion input should have four rows and may have multiple columns
function tang_comp = quat2tang(q)
    if(size(q,1) ~= 4)
        error('Quaternion input must have 4 rows!');
    end
    
    % normalize quaternion (it should be very close to a unit quaternion anyway...)
    q_in = q_in/norm(q_in);
    
    theta = 2*acos(q(1,:));
    tang_comp = (theta./sin(theta/2)).*q(2:4,:);
end