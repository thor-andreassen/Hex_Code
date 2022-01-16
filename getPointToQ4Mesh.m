function [projection_points,projection_distances,projection_normals]=getPointToQ4Mesh(elems,nodes,query_pts,use_parallel_loops)
        %% Function to determine distance between Query point and mesh of Q4 elements
        % the function is used to take a set of Q4 mesh elements, and calculate the
        % nearest location and distance to a set of query points for each query
        % point.
        %
        %
        % The function first calcualtes the approximate position of each
        % face/element of the q4 mesh as the average position of its corner nodes.
        % Then the function uses a KNN search with a KD tree to efficiently
        % calculate the nearest face to each of the query points. Following this,
        % the function takes each query point and its nearest face, and performs an
        % algorithm using the shape functions of the Q4 element to determine the
        % exact nearest point on the element based on minimizing the distance to
        % the surface for the Q4 element. The distance, normal and projection point
        % are calculated for each query point to the Q4 mesh.
        %
        %
        %
        %
        % Inputs:
                % elems: A matrix of connections for each Q4 element of the surface (N x 4)
                        % defining the node number of each of the 4 nodes. These elements should be
                        % number counter-clockwise to the surface witht eh surface normal pointed
                        % outward.
                % nodes: A matrix of nodes of x, y, z coordinates of all the ndoes of the
                        % Q4 mesh elements (N x 3)
                % query_pts: A matrix (M x 3) of points of x, y, z coordinates of all the query
                        % points to find the distance to the mesh
                % use_parallel_loops: 0 or 1 to use parallel loops (1) for increased
                        % efficiency to determine the distance to each points, or simply do
                        % it all in serial (0).
                        %
                        %
                        %
        % Outputs:
                % projection_points: A Matrix (M x 3) of the nearest point on the
                        % surface to each of the original corresponding query
                        % points. Each row is a (1 x 3) set of x, y , z coordinates
                        % of the nearest point on the surface to the corresponding
                        % row of the query point matrix
                % projection_distances: An array (M) of the distance betwen
                        % each query point and the nearest point on the Q4 surface
                        % mesh. The value is negative, if the distance is
                        % opposite the direction of the surface normal of
                        % the Q4 Mesh. Negative = "Inside", Positive =
                        % "Outside"
                % projection_normals: A Matrix (M x 3) of the nearest point on the
                        % surface to each of the original corresponding query
                        % points. Each row is a (1 x 3) set of x, y , z coordinates
                        % of the nearest point on the surface to the corresponding
                        % row of the query point matrix
        
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
                        % the following line gets the x, y ,z coordinate of
                        % the nodes on the face nearest the current query
                        % point based on the previous KNN search
                        node_face=nodes(elems(nearest_face(count_query_point),:),:);
                        x=node_face(:,1);
                        y=node_face(:,2);
                        z=node_face(:,3);
                        
                        % the following line uses a separate function to
                        % calculate the nearest projection point and the
                        % surface normal direction from the nearest face
                        % element to the current query point by minimizing
                        % the distance to teh element according to the
                        % shape functions of the Q4 element.
                        [projection_pt,surf_to_pt_normal,pt_distance]=getNearestPointToQ4(x,y,z,query_pts(count_query_point,:)',0);
                        projection_points(count_query_point,:)=projection_pt';
                        projection_distances(count_query_point)=pt_distance;
                        projection_normals(count_query_point,:)=surf_to_pt_normal';
                end
        else
                for count_query_point=1:size(query_pts,1)
                        node_face=nodes(elems(nearest_face(count_query_point),:),:);
                        x=node_face(:,1);
                        y=node_face(:,2);
                        z=node_face(:,3);
                        [projection_pt,surf_to_pt_normal,pt_distance]=getNearestPointToQ4(x,y,z,query_pts(count_query_point,:)',0);
                        projection_points(count_query_point,:)=projection_pt';
                        projection_distances(count_query_point)=pt_distance;
                        projection_normals(count_query_point,:)=surf_to_pt_normal';
                end
        end
end