%% clear
clear
close all
clc

%% load data
load('fem_cart_mesh.mat');
load('face_order.mat');
load('tib_cart_mesh.mat');
elems=elemlist_renum(:,2:end);
nodes=nodelist(:,2:end);

%% Find Outer Surface
[face_outer_surf,face_list,nodes_outer_surf]=get3DElementOuterSurface(elems,nodes);

%% plot elements
figure()
patch('Faces',face_outer_surf,'Vertices',nodes,'FaceColor','b','FaceAlpha',0.75);
figure()
patch('Faces',face_list,'Vertices',nodes,'FaceColor','r','FaceAlpha',0.75);

%% create query points
vals=randperm(size(query_nodes,1));
query_pt=query_nodes(vals(1:1000),2:end);

%% get distance from query points to nearest surface
tic,
[projection_points,projection_distances,projection_normals]=getPointToQ4Mesh(elems,nodes,query_pt,1);
toc
%% plotting surface normals
hold on
for count_query_point=1:size(query_pt,1)
        points=[projection_points(count_query_point,:);query_pt(count_query_point,:)];
        plot3(points(:,1),points(:,2),points(:,3),'r')
end
plot3(query_nodes(:,2),query_nodes(:,3),query_nodes(:,4),'go');

%% reduce patch
quadtic=tic;
[reduce_face,reduce_nodes]=reducepatch(face_outer_surf,nodes,0.1);
[Q4_faces, Q4_nodes]=convertTriToQ4Mesh(reduce_face,reduce_nodes);
toc(quadtic)
figure()
patch('Faces',face_outer_surf,'Vertices',nodes,'FaceColor','b','FaceAlpha',0.75);
patch('Faces',Q4_faces,'Vertices',Q4_nodes,'FaceColor','r','FaceAlpha',0.75);