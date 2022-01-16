%% clear
clear
close all
clc


%% load data
load('fem_cart_mesh.mat');
load('face_order.mat');
load('tib_cart_mesh.mat');
%% plot data
if size(elemlist,2)<=5
        face_order=face_order_tet;
        node_per_face=3;
        node_per_elem=4;
else
        face_order=face_order_hex;
        node_per_face=4;
        node_per_elem=8;
end

figure()
elems=elemlist_renum(:,2:end);
nodes=nodelist(:,2:end);

face_list=zeros(size(elems,1)*6,node_per_face);
counter=1;
for count_elems=1:size(elemlist)
        for count_face=1:size(face_order,1)
                faceel=elems(count_elems,face_order(count_face,:));
                face_list(counter,:)=faceel;
                counter=counter+1;
        end
end


patch('Faces',face_list,'Vertices',nodes,'FaceColor','r','FaceAlpha',0.75);

%% Find Outer Surface
face_list_surf=face_list;
face_list_surf_sort=sort(face_list_surf,2);
[~,remove_index]=removeAllDuplicateRows(face_list_surf_sort);
face_list_surf(remove_index,:)=[];


%% find outer surf nodes
face_list_surf_vec=reshape(face_list_surf,[],1);
face_list_surf_vec=unique(face_list_surf_vec);
nodes_surf=nodes(face_list_surf_vec,:);

figure()
patch('Faces',face_list_surf,'Vertices',nodes,'FaceColor','b','FaceAlpha',0.75);
% plot3(nodes_surf(:,1),nodes_surf(:,2),nodes_surf(:,3),'bx');


%% determine average face node
face_nodes_mean=zeros(size(face_list_surf,1),3);

for count_face=1:size(face_list_surf,1)
        nodel=face_list_surf(count_face,:);
        face_nodes=nodes(nodel,:);
        face_nodes_mean(count_face,:)=mean(face_nodes);
        
end
%% create point to edge surf
% query_pt=[20,40,-20];

rand_vals=randperm(size(query_nodes,1));

query_pt=query_nodes(rand_vals(1:2500),2:4);

tic
min_dist=Inf;
current_projection=[0;0;0];
current_normal=[1;1;1];

nearest_face=knnsearch(face_nodes_mean,query_pt);


projection_points=query_pt;
projection_distances=zeros(size(query_pt,1),1);
projection_normals=query_pt;
parfor count_query_point=1:size(query_pt,1)
        node_face=nodes(face_list_surf(nearest_face(count_query_point),:),:);
        x=node_face(:,1);
        y=node_face(:,2);
        z=node_face(:,3);
        [projection_pt,surf_to_pt_normal,distance,projection_nat]=getNearestPointToQ4(x,y,z,query_pt(count_query_point,:)',0);
        projection_points(count_query_point,:)=projection_pt';
        projection_distances(count_query_point)=distance;
        projection_normals(count_query_point,:)=surf_to_pt_normal';
end
toc


hold on
for count_query_point=1:size(query_pt,1)
        points=[projection_points(count_query_point,:);query_pt(count_query_point,:)];
        plot3(points(:,1),points(:,2),points(:,3),'r')
end

plot3(query_nodes(:,2),query_nodes(:,3),query_nodes(:,4),'go');