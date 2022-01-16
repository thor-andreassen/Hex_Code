function [Q4_faces, Q4_nodes]=convertTriToQ4Mesh(faces,nodes)
        all_face_node={};
        counter=1;
        Q4_faces=[];
        Q4_nodes=[];
        for count_face=1:size(faces,1)
                nodel=faces(count_face,:);
                face_nodes=nodes(nodel,:);
                % get new node locations
                center_node=mean(face_nodes);
                int1=mean([face_nodes(1,:);face_nodes(2,:)]);
                int2=mean([face_nodes(2,:);face_nodes(3,:)]);
                int3=mean([face_nodes(3,:);face_nodes(1,:)]);
                
                % create new faces
                face_node=[face_nodes(1,:);int1;center_node;int3];
                all_face_node{counter}=face_node;
                counter=counter+1;
                
                face_node=[face_nodes(2,:);int2;center_node;int1];
                all_face_node{counter}=face_node;
                counter=counter+1;
                
                face_node=[face_nodes(3,:);int3;center_node;int2];
                all_face_node{counter}=face_node;
                counter=counter+1;
        end
        
        for count_all_faces=1:length(all_face_node)
                current_face=all_face_node{count_all_faces};
                face_def=zeros(1,4);
                for count_node=1:4
                        current_node=current_face(count_node,:);
                        if size(Q4_nodes,1)<4
                                rid=[];
                        else
                                rid=find(Q4_nodes==current_node);
                        end
                        if isempty(rid) || count_all_faces==1
                                Q4_nodes=[Q4_nodes;current_node];
                                face_def(count_node)=size(Q4_nodes,1);
                        else
                                face_def(count_node)=rid(1);
                        end
                end
                Q4_faces=[Q4_faces;face_def];
        end
end