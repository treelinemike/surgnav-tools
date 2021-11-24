% encode location of principal point as four pixels of a grayscale image
% note: can't encode points within half of a pixel of the edge
function grayimg = encode_principalpoint(x,y,width,height,v_max)

% compute the base pixel number and desired delta to encode
base_x = floor(x);
base_y = floor(y);
delta_x = x-base_x;
delta_y = y-base_y;

% build an *underdetermined* linear system of equations, specifiying:
% 1) average pixel value should be 0.25*v_max s.t. at extremes one pixel can take entire value
% 2) correct encoding of delta_y (center of mass approach)
% 3) correct encoding of delta_x (center of mass approach)
% the missing constraint would ideally give as large a spread as possible
% between pixel values in the cells (so rounding has minimal effect) while
% also keeping all pixel values in [0, v_max]
A = [1 1 1 1; 0 1 0 1; 0 0 1 1];
b = [v_max; v_max*delta_y; v_max*delta_x];

% initial penalty on out-of-range pixel values
k = 0.1;

% minimize cost function, increasing penalty as needed to get pixel values
% in range
stop_flag = false;
while(~stop_flag)
    
    % set up and call fminsearch()
    X0 = 127*[1 0 0 1]';
    f = @(x_current)pix_cost(x_current,A,b,k,v_max);
    options = optimset('MaxFunEvals',1e6);
    [X_opt,J_opt] = fminsearch(f,X0,options);

    % stop if we have valid pixel values, otherwise increase the penalty on
    % out-of-range pixel values
    if(min(X_opt) >= 0 && max(X_opt) <= v_max)
        stop_flag = true;
    else
        k = 1.01*k;
    end

end

% need integer pixel shading values
X_opt = round(X_opt);

% % report actual encoded position
% x_recon = base_x+(1/sum(X_opt))*(X_opt(3)+X_opt(4));
% y_recon = base_y+(1/sum(X_opt))*(X_opt(2)+X_opt(4));
% fprintf('Set to (%0.3f,%0.3f)\n',x_recon,y_recon);

% shade apprpriate pixels in image
grayimg = uint8(zeros(height,width));
grayimg(base_y,base_x) = X_opt(1);
grayimg(base_y+1,base_x) = X_opt(2);
grayimg(base_y,base_x+1) = X_opt(3);
grayimg(base_y+1,base_x+1) = X_opt(4);

end

% cost function to balance encoding accuracy
% with keeping pixel values in valid range
function J = pix_cost(X,A,b,k,v_max)
resid = A*X-b;
J = resid'*resid + k*abs(sum(X(X<0))) + k*abs(sum(X(X>v_max)));
end