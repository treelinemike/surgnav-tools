function tang = matrix2tang(R)
    ss = logm(R); % skew-symmetric matrix
    tang = [-ss(2,3), ss(1,3), -ss(1,2)]';
end