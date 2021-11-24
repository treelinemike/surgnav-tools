% decode principal point from simple grayscale image
% using center of mass approach
function pp  = decode_principalpoint(grayimg)

% find indices of pixels that are nonzero in value
pixnums = find(grayimg > 0);

% find corresponding x and y coordinates of pixel centers
all_x = double(floor(pixnums/size(grayimg,1))+1);
all_y = double(mod(pixnums-1,size(grayimg,1))+1);

% get pixel values
all_val = double(grayimg(pixnums));

% compute center of mass in x and y directions
x = (dot(all_x,all_val))/sum(all_val);
y = (dot(all_y,all_val))/sum(all_val);

% return extracted principal point in a vector
pp = [x,y]';