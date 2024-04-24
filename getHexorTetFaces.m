function face_list=getHexorTetFaces(elems)
% this function calulates all of the faces for a set of Hexahedral or
% Tetrahedral elements.
        if size(elems,2)<=4
                face_order=[1,2,3;1,4,2;2,4,3;3,4,1];
                node_per_face=3;
                num_faces=4;
        else
                face_order=[1,2,3,4;5,8,7,6;1,5,6,2;2,6,7,3;3,7,8,4;4,8,5,1];
                node_per_face=4;
                num_faces=6;
        end
        face_list=zeros(size(elems,1)*num_faces,node_per_face);
        counter=1;
        for count_elems=1:size(elems,1)
                for count_face=1:size(face_order,1)
                        faceel=elems(count_elems,face_order(count_face,:));
                        face_list(counter,:)=faceel;
                        counter=counter+1;
                end
        end
end
