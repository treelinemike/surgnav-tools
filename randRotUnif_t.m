% sample rotations from an independent, multivariate uniform
% distribution over elements of the so(3) tangent space
function [t,delta_theta] = randRotUnif_t(t_mean, theta_max, N_samp)

% allocate array for output
t = zeros(3,N_samp);
delta_theta = zeros(1,N_samp);

% mean / DC rotation (without perturbation)
q_mean = tang2quat(t_mean);

% samplue using rejection method
N_accepted = 0;
loopCount = 0;

while( N_accepted < N_samp )
    U_samp = (2*rand(3,1)-1);
    % Note: Typically we would need to draw another random sample here,
    % this time from u(0,1) and compare that value to the ratio of the
    % f(x)/(c*g(x)) where f(x) is the density we want to sample from and
    % c*g(x) is the envelope function. Here we don't need the random draw
    % because f(x)/(c*g(x)) = 1 for all x inside the unit sphere and 0
    % outside. Thus, samples are always accepted if their norm is less than
    % 1.0.
    if( norm(U_samp) <= 1 )
        N_accepted = N_accepted + 1;
        samp_scaled = theta_max*U_samp;
        delta_theta(N_accepted) = norm(samp_scaled);
        t(:,N_accepted) =  quat2tang(quatmult(q_mean, tang2quat(samp_scaled) )) ;
    end
    loopCount = loopCount + 1;
end
% fprintf('Acceptance ratio: %5.2f%%\n',100*N_samp/loopCount);

end