function R = tang2matrix(tang)
R  = expm([0 -tang(3) tang(2); tang(3) 0 -tang(1); -tang(2) tang(1) 0]);

% ensure that R is orthogonal 
R = fixR(R);

end
