% plot a triad reference showing the position and orientation of a homogeneous transformation matrix TF
% the optinal second argument indicates length of 
function triad_struct = plotTriad(TF,varargin)
switch(nargin)
    case 1
        k = 0.3;
    case 2
        k = varargin{1};
    otherwise
        error('Too many arguments to plotTriad!');
end

triad = hTF(k*[zeros(3,1) eye(3)],TF,0)';
triad_struct.k = k;
triad_struct.ph_x = plot3([triad(1,1) triad(2,1)],[triad(1,2) triad(2,2)],[triad(1,3) triad(2,3)],'-','LineWidth',1.6,'Color',[0.8 0 0]);
triad_struct.ph_y = plot3([triad(1,1) triad(3,1)],[triad(1,2) triad(3,2)],[triad(1,3) triad(3,3)],'-','LineWidth',1.6,'Color',[0 0.8 0]);
triad_struct.ph_z = plot3([triad(1,1) triad(4,1)],[triad(1,2) triad(4,2)],[triad(1,3) triad(4,3)],'-','LineWidth',1.6,'Color',[0 0 0.8]);