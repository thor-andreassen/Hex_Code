function [faces_renumber,vertices_renumber]=renumberFacesAndVertices(faces,vertices)
        long_face=reshape(faces,[],1);
        unique_nodes=unique(long_face);
        unique_nodes=sort(unique_nodes);
        vertices_renumber=vertices(unique_nodes,:);
        faces_renumber=faces;
        for count_faces=1:size(faces,1)
                for count_nodes=1:size(faces,2)
                        [~,temp_id]=ismember(faces(count_faces,count_nodes),unique_nodes);
                        faces_renumber(count_faces,count_nodes)=temp_id;
                end
        end
end