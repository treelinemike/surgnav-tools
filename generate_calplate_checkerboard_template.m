% generate checkerboard template
% IN POLARIS TOOL COORDINATES!
% DIFFERS FROM MATLAB CHECKERBOARD COORDINATES!
% MESHGRID GIVES WRONG ORDER, SO DO THIS POINT-BY-POINT
function ckbd_tmp = generate_calplate_checkerboard_template(N_x,N_y,ckbd_square_size,z_offset)
N_pts = prod([N_x, N_y]-1);
ckbd_tmp = nan(N_pts,3);
for pointIdx = 1:N_pts
    ckbd_tmp(pointIdx,:) = -1*ckbd_square_size*[mod(pointIdx-1,N_x-1)+1, ceil((pointIdx)/(N_x-1)), 0];
    ckbd_tmp(pointIdx,3) = z_offset;  % [mm] z offset of checkerboard plane in calplate polaris tool frame
end