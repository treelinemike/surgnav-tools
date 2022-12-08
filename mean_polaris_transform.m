function [TF] = mean_polaris_transform(t,q,varargin)

% error checking
if( size(t,1) ~= 3)
    error('Translation matrix must have 3 rows!');
end
if( size(q,1) ~= 4)
    error('Quaternion matrix must have 4 rows!');
end
if( size(t,2) ~= size(q,2)  )
    error('Translation and quaternion matrices must have same number of columns!');
end

% convert rotation to tangential representation
r = quat2tang(q);

% if 3rd parameter passed in, we are filtering by standard deviation
if(nargin > 2)

    % get threshold
    std_threshold = varargin{1};

    % check translation for severe deviations
    t_mean = mean(t,2);
    t_std = std(t,0,2);
    t_dev = t-t_mean;
    t_stdevs = abs( t_dev ./ repmat(t_std,1,size(t,2)) );
    crop_mask_t = logical(sum( t_stdevs > std_threshold , 1));

    % check rotation for severe deviations
    r_mean = mean(r,2);
    r_std = std(r,0,2);
    r_dev = r-r_mean;
    r_stdevs = abs( r_dev ./ repmat(r_std,1,size(r,2)) );
    crop_mask_r = logical(sum( r_stdevs > std_threshold , 1));

    % apply composite crop mask
    crop_mask = crop_mask_t | crop_mask_r;
%     fprintf('Rejecting %d points...\n',nnz(crop_mask_r));
    t = t(:,~crop_mask);
    r = r(:,~crop_mask);
end

% average translation and rotation
t_avg = mean(t,2);
r_avg = mean(r,2);

% construct homogenous transformation matrix
TF = eye(4);
TF(1:3,1:3) = tang2matrix(r_avg);
TF(1:3,4) = t_avg;

% make sure we're not delivering a bad transform
assert(abs(det(TF(1:3,1:3))-1.0) < 1e-4,'Invalid rotation!')
assert(nnz(isnan(TF)) == 0,'NaNs present in TF!');

end