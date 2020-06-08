% Uniformly sample rotations in the following sense:
% 1. Axis of rotation sampled uniformly from S^2 (surface of 2-sphere... i.e.
% standard sphere)
% 2. Angle of rotation about that axis sampled uniformly on [0,theta_max]
% The result are rotations whose marginal angle and axis of rotation 
% distributions are both uniform. The alternate approach, sampling uniformly
% inside the 3-ball and multiplying by theta-max produces a higher density
% of high angle rotations 
function [t,delta_theta] = randRotUnifAng_t(t_mean, theta_max, N_samp)

% allocate array for output
t = zeros(3,N_samp);
delta_theta = zeros(1,N_samp);

% mean / DC rotation (without perturbation)
q_mean = tang2quat(t_mean);

% samplue using rejection method
N_accepted = 0;
loopCount = 0;

% sample uniformly on the unit sphere S^2 via Muller method (relationship
% between sphere and Gaussian function)... this gives unit vectors
% corresponding to axes of rotation
u = unitvec(mvnrnd(zeros(1,3),eye(3),N_samp)');

% now sample the angles of rotation uniformly on a segment of the real line
delta_theta = theta_max*rand(1,N_samp);

% scale unit vectors by sampled angles
t_perturb = u.*delta_theta;

% compose perturbation rotation with mean rotation
for sampIdx = 1:N_samp 
    t(:,sampIdx) =  quat2tang(quatmult(q_mean, tang2quat(t_perturb(:,sampIdx)) )) ;
end

end