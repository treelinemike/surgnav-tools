% compute the masked image
% seg_mask values must be non-negative integers
function img8_masked = maskImage(img8_gray,seg_mask,seg_colors)

% check input
if(size(img8_gray,3) ~= 1)
    error('Input image must be 1-plane grayscale');
end
if(size(seg_mask,3) ~= 1)
    error('Segmentation mask must be 1-plane grayscale');
end
if( ~prod( size(img8_gray) == size(seg_mask)) )
    error('Image and segmentation mask must be the same size');
end

% compute base HSV image
img8_masked_hsv = rgb2hsv(repmat(img8_gray,1,1,3));

% color each label separately
allLabels = unique(seg_mask(:),'sorted');
for labelIdx = 1:length(allLabels)
    
    % get the current label
    thisLabel = allLabels(labelIdx);
    
    % determine color to paint this label
    % NOTE: LABEL MUST BE AN INTEGER
    colorIdx = thisLabel+1;
    
    % paint label in this image
    thisLabelMask = (seg_mask == thisLabel);
    thisColorHSV = rgb2hsv(seg_colors(colorIdx,:));
    img8_masked_hsv(:,:,1) = img8_masked_hsv(:,:,1) + thisColorHSV(1)*thisLabelMask;
    img8_masked_hsv(:,:,2) = img8_masked_hsv(:,:,2) + thisColorHSV(2)*thisLabelMask;
end

% convert back to RGB
img8_masked = hsv2rgb(img8_masked_hsv);
end