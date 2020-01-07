function areaList = makmesh_oneRingAreas(thisMesh,varargin)

% allow second input argument to be a list of vertex indices whose one ring areas
% should be computed. if second argument is empty function will return
% one-ring areas of all triangles
switch nargin
    case 1
        vertexQueryList = (1:size(thisMesh.Points,1))';
    case 2
        vertexQueryList = varargin{1};
    otherwise
        error('Invalid number of input arguments');
end

areaList = zeros(length(vertexQueryList),1);
triVertices = thisMesh.ConnectivityList;
if(size(triVertices,2) ~= 3)
    error('Mesh does not seem to be triangular...');
end

for vertexQueryIdx = 1:length(vertexQueryList)
    thisVertex = vertexQueryList(vertexQueryIdx);
    triList = find( (triVertices(:,1) == thisVertex) | (triVertices(:,2) == thisVertex) | (triVertices(:,3) == thisVertex) );
    areaList(vertexQueryIdx) = sum(makmesh_triarea(thisMesh,triList));
end
    
end