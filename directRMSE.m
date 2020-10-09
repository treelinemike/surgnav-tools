% compute RMSE between two paired point clouds
% uses error between corresponding points in each point cloud
% pc1, pc2 are point clouds with one row per point; columns are features
% (i.e. coordinates)

function rmse = directRMSE(pc1,pc2)

% make sure point clouds being compared are the same size
if( min(size(pc1) == size(pc2)) < 1 )
    error('Point clouds must be same shape!');
end

% compute error and RMSE
err = pc1-pc2;
rmse = sqrt(mean(diag( err*err')));

end