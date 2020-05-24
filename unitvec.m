% compute the unit vector correspoinding to a given vector
% if direction is not specified, defaults to first dimension greater than 1
% just as in vecnorm()
%
% TODO: extend to higher dimensions, only works for 2D arrays now
function v_out = unitvec( v_in, direction )

% if no direction given, select first dimension whose size is > 1
if(nargin == 1)
    inputSize = size(v_in);
    direction = find(inputSize > 1,1,'first');
    if(isempty(direction))
        direction = 1;
    end
end

% compute unit vector along chosen dimension
switch(direction)
    case 1
        v_out = v_in./repmat(vecnorm(v_in,2,1),size(v_in,1),1);
    case 2
        v_out = v_in./repmat(vecnorm(v_in,2,2),1,size(v_in,2));
    otherwise
        error('Invalid direction.');
end