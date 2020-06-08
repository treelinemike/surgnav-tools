% sample rotations from an independent, multivariate Gaussian
% distribution over elements of the so(3) tangent space
function [t, delta_theta] = randRotGauss_t(t_mean, sigma, N_samp)

% allocate array for output
t = zeros(3,N_samp);
delta_theta = zeros(1,N_samp);

% mean / DC rotation (without perturbation)
q_mean = tang2quat(t_mean);

% define covariance in tangent space
% that is, vectors whose elements are [theta_x, theta_y, theta_z]
COV_tang = diag(sigma.^2);

p_samp = mvnrnd([0 0 0],COV_tang,N_samp)';  % gaussian sampling for PERTURBATION FROM MEAN only
p_samp_angax = tang2angax(p_samp);
delta_theta = p_samp_angax(1,:);
q_samp = tang2quat(p_samp);
 
% combine perturbation with base DC rotation
% TODO: can we eliminate this loop by enhancing quatmult()?
for sampIdx = 1:N_samp
    q_total = quatmult(q_mean,q_samp(:,sampIdx));
    t_total = quat2tang(q_total);
    t(:,sampIdx) = t_total;
end

end