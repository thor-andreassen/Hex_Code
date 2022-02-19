function [projection_points,projection_distances,projection_normals]=...
        getPointToQ4MeshApproximate(elems,nodes,query_pts,use_parallel_loops)
        
        % The following lines determine the average node
        % coordinate of each element of the Q4 mesh
        face_nodes_mean=zeros(size(elems,1),3);
        for count_face=1:size(elems,1)
                nodel=elems(count_face,:);
                face_nodes=nodes(nodel,:);
                face_nodes_mean(count_face,:)=mean(face_nodes);
        end
        
        % the following line determine the nearest face to each of the
        % query points using a KNN search with a KD tree.
        nearest_face=knnsearch(face_nodes_mean,query_pts);
        
        % the following lines initilize the values for the projection
        % points, distances, and normals.
        projection_points=query_pts;
        projection_distances=zeros(size(query_pts,1),1);
        projection_normals=query_pts;
        
         if use_parallel_loops
                parfor count_query_point=1:size(query_pts,1)
                        node_face=nodes(elems(nearest_face(count_query_point),:),:);
                        x=node_face(:,1);
                        y=node_face(:,2);
                        z=node_face(:,3);
                        
                        [quad_normal,face_centroid]=findQ4SurfaceNormal(node_face);
                        [pt_distance,projection_pt]=findNearestPointToPlane(query_pts(count_query_point,:),quad_normal,face_centroid);

                        projection_points(count_query_point,:)=projection_pt;
                        projection_distances(count_query_point)=pt_distance;
                        projection_normals(count_query_point,:)=quad_normal;
                end
        else
                for count_query_point=1:size(query_pts,1)
                                                node_face=nodes(elems(nearest_face(count_query_point),:),:);
                        x=node_face(:,1);
                        y=node_face(:,2);
                        z=node_face(:,3);
                        
                        [quad_normal,face_centroid]=findQ4SurfaceNormal(node_face);
                        [pt_distance,projection_pt]=findNearestPointToPlane(query_pts(count_query_point,:),quad_normal,face_centroid);

                        projection_points(count_query_point,:)=projection_pt;
                        projection_distances(count_query_point)=pt_distance;
                        projection_normals(count_query_point,:)=quad_normal;
                end
        end
        
        
        
end