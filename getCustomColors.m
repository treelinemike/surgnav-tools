% define colors for plotting
%
% To use specified color order for a single set of axes:
% figure; ax = axes('ColorOrder',colors); plot(rand(10),'LineWidth',3); legend;
%
% MATLAB's standard colors can be retrieved by:
% get(groot,'defaultAxesColorOrder')
% 
% Standard colors can be overwritten with:
% set(groot,'defaultAxesColorOrder',colors)
%
% To revert to MATLAB defaults:
% set(groot,'defaultAxesColorOrder','remove')
%
% ref: https://www.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html#budumk7_sep_shared-ColorOrder
%
% optional input argument: getStandardColors(setDefault)
%                              setDefault not provided: just return matrix
%                                                       of custom colors
%                              setDefault == 1:         set custom colors as default for
%                                                       all new axes, and return
%                                                       the array of colors
%                              setDefault == 0:         return MATLAB
%                                                       default colors and set them as default for
%                                                       all new plots
function colors = getCustomColors(varargin)

% custom color order
colors = [
    0.7 0.0 0.0; ...
    1.0 0.7 0.0; ...
    0.7 0.7 0.0; ...
    0.0 0.7 0.0; ...
    0.0 0.0 0.7; ...
    0.7 0.0 1.0 ];

% set or revert MATLAB color order if desired
if(nargin)
   if(varargin{1} == 1)
       set(groot,'defaultAxesColorOrder',colors);
   elseif(varargin{1} == 0)
       set(groot,'defaultAxesColorOrder','remove');
       colors = get(groot,'defaultAxesColorOrder');
   end
end