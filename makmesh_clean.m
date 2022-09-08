function [F_new, V_new] = makmesh_clean(F, V)

% first remove any unused vertices
[F_new, V_new] = makmesh_removeUnusedVertices(F, V);

% now consolidate any duplicate vertices
[V_new,map_a2c,map_c2a] = unique(V_new,'rows','stable');
% thisMesh = triangulation(F_new,V_new);
% assert(nnz(V_new - thisMesh.Points( map_a2c,:)) == 0,'Mapping error (map_a2c)!');
% assert(nnz(thisMesh.Points-V_new(map_c2a,:)) == 0,'Mapping error (map_c2a)!');
F_new = map_c2a(F_new);

% finally, remove repeated faces
F_new = unique(F_new,'rows','stable');