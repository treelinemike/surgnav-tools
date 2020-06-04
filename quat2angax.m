function angax = quat2angax(q)
angax = zeros(4,1);
halftheta = acos(q(1));
if(halftheta < 10*eps)
    angax = [0 0 0 0]';
else
    angax(1) = 2*halftheta;
    angax(2:4) = (1/sin(halftheta))*q(2:4);
end
end