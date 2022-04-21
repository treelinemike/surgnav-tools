function [T,pc_fit,rmse,iters] = iterateICP( pc_moving, pc_fixed, rmse_threshold)

pc_moving = pointCloud(pc_moving);
pc_fixed = pointCloud(pc_fixed);

prev_rmse = 0;
[tform,pc_moving,rmse] = pcregistercpd(pc_moving,pc_fixed,'Transform','Rigid'); % (moving, fixed) need to use obs as moving!
T = tform.T;

iters = 1;
% while( abs(rmse-prev_rmse) > 0.001)
%     prev_rmse = rmse;
%     [tform,pc_moving,rmse] = pcregistercpd(pc_moving,pc_fixed,'Transform','Rigid'); % (moving, fixed) need to use obs as moving!
%     T = T*tform.T; 
%     iters = iters + 1;
% end

% while( abs(rmse-prev_rmse) > 0.001)
%     prev_rmse = rmse;
%     [tform,pc_moving,rmse] = pcregistericp(pc_moving,pc_fixed); % (moving, fixed) need to use obs as moving!
%     T = T*tform.T; 
%     iters = iters + 1;
% end

pc_fit = pc_moving.Location;