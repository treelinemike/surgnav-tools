% gibbsSampleRect.m
% Mike Kokko
% 14-May-2020
%
% Sample from density whose values are given as inputs at every point on an
% n-dimensional grid
%
% x_qp:        Query points (i.e. discritized state space) - must be a
%              rectangular grid in n-dimensions; x_qp is n x m where m is the
%              number of points in state space; order of columns is the same as
%              when n-dim array A is serialized in MATLAB via A(:), that is,
%              fastest changes along the x1 dimenstion, slowes along the xn dim...
%
% pdf:         m x 1 vector with each element corresponding to density of the
%              point encoded in the corresponding column of x_qp
%
% dimLengths:  1 x n row vector where the ith element 
%
% Nsamp:       Number of samples from pdf_qp to return 
%
% gibbsBurnIn: Number of samples to discard at beginning of Markov chain
% 
% gibbsM:      After burn in period, will save every m-th sample until
%              Nsamp samples are collected

function samples = gibbsSampleRect(x_qp, pdf_qp, dimLengths, Nsamp, gibbsBurnIn, gibbsM)

% compute total number of Gibbs steps to take
% we wil discard points in the burn in period
% and only accrue every m-th sample afterward
Nsteps = gibbsBurnIn + 1 + gibbsM*(Nsamp-1); 

% start sampler at random query point
x0Idx = randi(size(x_qp,2));
x0 = x_qp(:,x0Idx);

% start history
x = x0;
xIdx = x0Idx;
x_hist = NaN(size(x_qp,1),Nsteps+1);
x_hist(:,1) = x0;
xIdx_hist = NaN(1,Nsteps+1);
xIdx_hist(1) = x0Idx;

% iterate sampler
for gibbsIter = 1:Nsteps
    for dimIdx = 1:size(x_qp,1)
        
        % extract indices for all points in a line along the selected
        % dimension that includes the current point
        try
        subscripts = ndind2sub(dimLengths,xIdx);
        catch
           xIdx 
        end
        
        pointSubscripts = repmat(subscripts,dimLengths(dimIdx),1);
        pointSubscripts(:,dimIdx) = (1:dimLengths(dimIdx))';
        ind = ndsub2ind(dimLengths,pointSubscripts);
        
        % compute 1D PDF and CDF along this line
        pointsAlongDim = x_qp(:,ind);
        distAlongDim = pointsAlongDim - pointsAlongDim(:,1);
        distAlongDim = vecnorm(distAlongDim,2,1);
        normFactor = trapz(distAlongDim,pdf_qp(ind));
        
        % use a flat PDF if we are sampling a portion of state space with
        % nearly zero density
        % need this to avoid div by zero
        % TODO: is 0.0001 the optimal threshold? could use strictly equal
        % to zero...
        if( normFactor < 0.0001 )
            line_pdf = (1/distAlongDim(end))*ones(length(ind),1);
        else
            line_pdf = pdf_qp(ind)/normFactor;
        end
        
        
        % compute and sample a point from the CDF
        line_cdf = cumtrapz(distAlongDim,line_pdf);
        localIdx = find(line_cdf >= rand(1),1,'first');
        xIdx = ind(localIdx);
        x = x_qp(:,xIdx);
        
    end
    
    % after stepping once along each eigendirection,
    % store new point as next node in markov chain
    x_hist(:,gibbsIter+1) = x;
    xIdx_hist(gibbsIter+1) = xIdx;
       
end

% keep only selected points from the markov chain
samples = x_hist(:,((gibbsBurnIn+1):gibbsM:Nsteps));