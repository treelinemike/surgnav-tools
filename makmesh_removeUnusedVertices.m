% remove unused vertices from vertex list
function [F_new,V_new] = makmesh_removeUnusedVertices(F,V)
oldVertexList = unique(F(:));
F_new = zeros(size(F));
for vertexIdx = 1:length(oldVertexList)
    F_new(F(:) == oldVertexList(vertexIdx)) = vertexIdx;
end
V_new = V(oldVertexList,:);
end