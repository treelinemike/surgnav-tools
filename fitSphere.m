% fit a sphere to a three-dimensional point cloud
% obs = [x, y, z] of size (n x 3) -> x, y, and z components of observed points in columns
% sphereParams = [x0, y0, z0, r]'
function [sphereParams, sse] = fitSphere( obs )

% error checking on input
if(size(obs,2) ~= 3)
    error('Observation input must have three columns corresponding to measured x, y, z positions.');
elseif(size(obs,1) < 4)
    error('Minimum 4 observations required.');
end

% starting point for optimization
obs_shift = obs-mean(obs);
r_approx = mean(sqrt(obs_shift(:,1).^2 + obs_shift(:,2).^2 + obs_shift(:,3).^2)); % a good guess...
params0 = [ mea n(obs(:,1)), mean(obs(:,2)), mean(obs(:,3)), r_approx ]';

% assemble observations and a variable for paramters
% into an anonymous function to be called by fminsearch
% note: necessary because... 
f = @(params)radialSSE(params,obs);

% run optimization and return result
% least squares approach
[sphereParams, sse] = fminsearch(f,params0);

% RANSAC approach
% sphereModel = pcfitsphere(pointCloud(obs),0.1);
% sphereParams = [sphereModel.Center'; sphereModel.Radius];
% sse = radialSSE(sphereParams,obs);

end


% objective function for optimization (MATLAB fminsearch())
% obs = [x, y, z] of size (n x 3)
% params = [x0, y0, z0, r]'
function sse = radialSSE(params,obs)
err = sqrt((obs(:,1)-params(1)).^2 + (obs(:,2)-params(2)).^2 + (obs(:,3)-params(3)).^2) - params(4);
sse = err'*err;
end