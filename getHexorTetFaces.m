function face_list=getHexorTetFaces(elems)
% this function calulates all of the faces for a set of Hexahedral or
% Tetrahedral elements.
        if size(elems,2)<=4
                face_order=[3,2,1;2,3,4;3,1,4;1,2,4];
                node_per_face=3;
        else
                face_order=[4,3,2,1;5,6,7,8;1,2,6,5;2,3,7,6;3,4,8,7;4,1,5,8];
                node_per_face=4;
        end
        face_list=zeros(size(elems,1)*6,node_per_face);
        counter=1;
        for count_elems=1:size(elems,1)
                for count_face=1:size(face_order,1)
                        faceel=elems(count_elems,face_order(count_face,:));
                        face_list(counter,:)=faceel;
                        counter=counter+1;
                end
        end
end