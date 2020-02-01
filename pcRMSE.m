% Try computing RMSE between two point clouds
% Note: knnsearch(X,Y) finds nearest neighbor in X for each point in Y
%
% Inputs: ref_points and test_points must have the same number of columns
% (# of independent variables)
%
% NOTE: There is a difference between computing error:
%       a) between points in the model and closest points on true surface
%       b) between points in the true surface and closest points on the
%       model
%
% Results should be similar to the RMSE values returned by the MATLAB ICP
% algorithm... 
%
% Inspired by MATLAB pcregistericp() function.
%
function rmse = pcRMSE( ref_points, test_points)

knnIdx = knnsearch(ref_points, test_points);
rmse = sqrt( sum(vecnorm(ref_points(knnIdx,:)-test_points,2,2).^2)/size(test_points,1));

% the following approach might produce higher errors if test points fit a portion of the
% reference points well but portions of the reference points deviate
% greatly from the test point clound
% knnIdx = knnsearch(test_points, ref_points);
% err2 = sqrt( sum(vecnorm((test_points(knnIdx,:)-ref_points),2,2).^2)/size(ref_points,1))

end