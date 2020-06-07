% rotate one vector in R^3 (v) by one or more perturbation rotations expressed in
% tangent space representation {t_i: t_i = theta_i*unitvec_i}

function v_out = rot1vec_t(v,t)

    % basic error checking
    if(size(v,1) ~= 3 || size(v,2) ~= 1)
       error('Input vector must be 3x1.');
    end
    if(size(t,1) ~= 3)
        error('Input tangent space rotation must be 3xN.');
    end

    % allocate output
    N_samp  = size(t,2);
    v_out = zeros(size(t));

    % rotate input vector by every transformation provided
    for sampIdx = 1:N_samp
        q = tang2quat(t(:,sampIdx));
        v_out(:,sampIdx) = quatrotate(q,v);
    end
    
end