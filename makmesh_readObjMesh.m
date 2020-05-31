function thisMesh = makmesh_readObjMesh(fileName)
%     close all; clear all; clc;
%     fileName = 'C:\Users\f002r5k\Desktop\skeleton-demo\models\elk.obj';
    [A,B,C,D] = textread(fileName,'%s %f %f %f','commentstyle','shell');
    allData = [B C D];
    faceMask = strcmp(A,'f')
    thisMesh = triangulation( allData(faceMask,:), allData(~faceMask,:) );
%     plot3(thisMesh.Points(:,1),thisMesh.Points(:,2),thisMesh.Points(:,3),'b.','MarkerSize',10);
%     axis equal
end