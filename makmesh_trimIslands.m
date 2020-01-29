% clean up mesh with isolated or sparsely connected faces
% returns ConnectivityList (cleanedFaces) as well as indices of remaining
% faces in the original mesh
function [cleanedFaces,faceIDs] = makmesh_trimIslands(faces,vertices)

% compute neighboring faces
neighbList = neighbors(triangulation(faces,vertices));

% construct list of connections between faces
% and remove all NaNs (come from neighbors() as padding when no connection
% exists)
st = [ repmat((1:size(neighbList,1))',3,1) reshape(neighbList,[],1) ];
st(isnan(st(:,2)),:) = [];

% convert connection informaiton into a graph
% each node in graph corresponds to a face in the mesh
g = simplify(graph(st(:,1),st(:,2),[],cellstr(num2str((1:size(faces,1))')))); % need to label faces b/c rmnode() renumbers!

% remove all nodes of degree 0 or 1 (isolated faces or faces with only one neighbor)
while(sum(degree(g) <= 1) > 0)
    g = rmnode(g,find(degree(g) <= 1)); % note: rmnode() renumbers nodes so need node labels
end

% remove all faces not in the largest connected component
% TODO: may want to change this to all faces in connected groups of size
% below a threshold
[bins,binsizes] = conncomp(g);
while( min(binsizes) < 0.1*max(binsizes))
    [~,smallestBinIdx] = min(binsizes);
    g = rmnode(g,find(bins == smallestBinIdx));
    [bins,binsizes] = conncomp(g);
end

% extract indices of faces that remain in graph
% or return empty array if no nodes (faces) remain
if( size(g.Nodes,1) > 0 )
    faceIDs = str2num(cell2mat(table2array(g.Nodes)));
    cleanedFaces = faces(faceIDs,:);
else
    cleanedFaces = [];
end

end
