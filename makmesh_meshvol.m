% calculate volume enclosed by mesh using the divergence theorem
% TODO: should first check mesh to ensure it is a single closed volume
function vol = makmesh_meshvol(thisMesh)
    faceList = thisMesh.ConnectivityList;
    incenters = thisMesh.incenter;
    areas = makmesh_triarea(thisMesh);
    faceNormals = thisMesh.faceNormal;
    vol = 0;
    for i = 1:size(faceList,1)
        vol = vol + (1/3)*dot(incenters(i,:)',faceNormals(i,:)')*areas(i);
    end
end
