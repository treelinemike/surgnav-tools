% compute the area of a mesh triangle given its index
function area = makmesh_triarea(thisMesh,varargin)

% allow second input argument to be a list of triangle indices whose areas
% should be computed. if second argument is empty function will return area
% of all triangles
switch nargin
    case 1
        triQueryList = (1:size(thisMesh.ConnectivityList,1))';
    case 2
        triQueryList = varargin{1};
    otherwise
        error('Invalid number of input arguments');
end

area = zeros(length(triQueryList),1);
V = thisMesh.Points;

for thisQueryIdx = 1:length(triQueryList)
    thisTriIdx = triQueryList(thisQueryIdx);
    triVertices = V(thisMesh.ConnectivityList(thisTriIdx,:),:);
    if(size(triVertices,1) ~= 3)
        error('Invalid number of triangle vertices (should be 3, of course)...');
    end
    vec1 = (triVertices(2,:)-triVertices(1,:))';
    vec2 = (triVertices(3,:)-triVertices(1,:))';
    area(thisQueryIdx) = 0.5*norm(cross(vec1,vec2));
end

end