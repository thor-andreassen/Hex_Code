function [quad_normal,face_centroid]=findQ4SurfaceNormal(nodes_face)

        quad_normals=zeros(4,3);
        face_centroid=mean(nodes_face);
        
        % node 1 normal
        vec1=nodes_face(2,:)-nodes_face(1,:);
        vec2=nodes_face(4,:)-nodes_face(1,:);
        quad_normals(1,:)=cross(vec1,vec2)/norm(cross(vec1,vec2));
        cent_vec=nodes_face(1,:)-face_centroid;
%         if dot(quad_normals(1,:),cent_vec)<0
%                 quad_normals(1,:)=-quad_normals(1,:);
%         end
        
        % node 2 normal
        vec1=nodes_face(3,:)-nodes_face(2,:);
        vec2=nodes_face(1,:)-nodes_face(2,:);
        quad_normals(2,:)=cross(vec1,vec2)/norm(cross(vec1,vec2));
        cent_vec=nodes_face(2,:)-face_centroid;
%         if dot(quad_normals(2,:),cent_vec)<0
%                 quad_normals(2,:)=-quad_normals(2,:);
%         end
        
        % node 3 normal
        vec1=nodes_face(4,:)-nodes_face(3,:);
        vec2=nodes_face(2,:)-nodes_face(3,:);
        quad_normals(3,:)=cross(vec1,vec2)/norm(cross(vec1,vec2));
        cent_vec=nodes_face(3,:)-face_centroid;
%         if dot(quad_normals(3,:),cent_vec)<0
%                 quad_normals(3,:)=-quad_normals(3,:);
%         end
        
        % node 4 normal
        vec1=nodes_face(1,:)-nodes_face(4,:);
        vec2=nodes_face(3,:)-nodes_face(4,:);
        quad_normals(4,:)=cross(vec1,vec2)/norm(cross(vec1,vec2));
        cent_vec=nodes_face(4,:)-face_centroid;
%         if dot(quad_normals(4,:),cent_vec)<0
%                 quad_normals(4,:)=-quad_normals(4,:);
%         end
        quad_normal=mean(quad_normals);
        quad_normal=quad_normal/norm(quad_normal);
        
%         %% plot data
%         surf_nodes=[nodes_face;face_centroid];
%         surf_normals=[quad_normals;quad_normal];
%         elems=[1,2,3,4];
%         patch('Faces',elems,'Vertices',nodes_face,'FaceColor','r');
%         hold on
%         quiver3(surf_nodes(:,1),surf_nodes(:,2),surf_nodes(:,3),...
%                 surf_normals(:,1),surf_normals(:,2),surf_normals(:,3));
%         plot3(face_centroid(1),face_centroid(2),face_centroid(3),'bx');
end