% sample from density whose values are given as inputs at every point on an
% n-dimensional grid
function samples = gibbsSampleRect(xq_cp,pdf,gibbsBurnIn, gibbsM)

% % % % assemble query point vectors for each eigen-direction
% % % xq_vec = [];
% % % dimLengths = [];
% % % for dimIdx = 1:nDim
% % %     sd = sqrt( val(dimIdx,dimIdx));
% % %     xq_vec{dimIdx} = -NSD*sd:hss:NSD*sd;
% % %     dimLengths(dimIdx) = length(xq_vec{dimIdx});
% % % end
% % % xq_cp_raw = cartprod(xq_vec)';
% % % xq_cp = mu + vec*xq_cp_raw; % now in EIGENSPACE! .. call to cartprod() is fast
% % % 
% % % ks_pdf = mvksdensity(x_samp_pre',xq_cp','Kernel','epanechnikov','weights',q_samp,'bandwidth',bwScale*bw_opt);

% start sampler at random query point
x0Idx = randi(size(xq_cp,2));
x0 = xq_cp(:,x0Idx);

% compute total number of Gibbs steps to take
Nsteps = gibbsBurnIn + 1 + gibbsM*(Np-1); 

% start history
x = x0;
xIdx = x0Idx;
x_hist = NaN(size(xq_cp,1),Nsteps+1);
x_hist(:,1) = x0;
xIdx_hist = NaN(1,Nsteps+1);
xIdx_hist(1) = x0Idx;

% iterate sampler
for gibbsIter = 1:Nsteps
    for dimIdx = 1:nDim
        
        % extract indices for all points in a line along the selected
        % dimension that includes the current point
        subscripts = ndind2sub(dimLengths,xIdx);
        pointSubscripts = repmat(subscripts,length(xq_vec{dimIdx}),1);
        pointSubscripts(:,dimIdx) = (1:length(xq_vec{dimIdx}))';
        ind = ndsub2ind(dimLengths,pointSubscripts);
        
        % compute 1D PDF and CDF along this line
        pointsAlongDim = xq_cp(:,ind);
        distAlongDim = pointsAlongDim - pointsAlongDim(:,1);
        distAlongDim = vecnorm(distAlongDim,2,1);
        normFactor = trapz(distAlongDim,ks_pdf(ind));
        pdf = ks_pdf(ind)/normFactor;
        cdf = cumtrapz(distAlongDim,pdf);
        
        % sample a point from the CDF
        localIdx = find(cdf >= rand(1),1,'first');
        xIdx = ind(localIdx);
        x = xq_cp(:,xIdx);       
    end
    
    % after stepping once along each eigendirection,
    % store new point as next node in markov chain
    x_hist(:,gibbsIter+1) = x;
    xIdx_hist(gibbsIter+1) = xIdx;
       
end

% keep only selected points from the markov chain
samples = x_hist(:,((gibbsBurnIn+1):gibbsM:Nsteps));