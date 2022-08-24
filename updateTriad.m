function updateTriad(triad_struct,TF)

triad = hTF(triad_struct.k*[zeros(3,1) eye(3)],TF,0)';

triad_struct.ph_x.XData = [triad(1,1) triad(2,1)];
triad_struct.ph_x.YData = [triad(1,2) triad(2,2)];
triad_struct.ph_x.ZData = [triad(1,3) triad(2,3)];

triad_struct.ph_y.XData = [triad(1,1) triad(3,1)];
triad_struct.ph_y.YData = [triad(1,2) triad(3,2)];
triad_struct.ph_y.ZData = [triad(1,3) triad(3,3)];

triad_struct.ph_z.XData = [triad(1,1) triad(4,1)];
triad_struct.ph_z.YData = [triad(1,2) triad(4,2)];
triad_struct.ph_z.ZData = [triad(1,3) triad(4,3)];

end