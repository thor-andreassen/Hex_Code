function [face_outer_surf,face_list,nodes_surf,nodes_outer_surf_coords]=get3DElementOuterSurface(elems,nodes)
        %% Determine the outer surface, and nodes for a given 3D mesh
        % the function takes in a list of 3D elements, and nodes, and
        % calculates the list of faces on the outer mesh,as well as all
        % inner faces. It can also calculate the list of all node locations
        % on the outer surface if desired.
        
        % inputs:
                % elems: connection list (N x 4 or N x 8) of all 3d elements (either tetrahedral 4
                        % node elements, or hexahedral 8 node elements)
                % nodes: x,y,z coordinates of all nodes (M x 3)

        % Outputs:
                % face_outer_surf: face definitions of all faces on the outer
                        % surface of the 3D elements. For Tetrahedral elements, these will
                        % be tri elements, for Hexahedral elements these will be q4
                        % elements.
                % face_list: all face definitions for all elements,
                        % including internal faces
                % nodes_outer_surf: x, y, z coordinates of all nodes on the outer
                        % surface of the elements.
                
        % the following line determines all the faces of all elements 
        face_list=getHexorTetFaces(elems);
        
        % the following lines sort the faces by node numbers, and remove
        % all instances of faces with the same set of nodes. Any faces that
        % remain are those that are not connected to any other face of any
        % other element, and as such are all the faces at the surface.
        face_outer_surf=face_list;
        face_list_surf_sort=sort(face_outer_surf,2);
        [~,remove_index]=removeAllDuplicateRows(face_list_surf_sort);
        face_outer_surf(remove_index,:)=[];

        % the following lines determine all the node numbers on the outer
        % surface
        nodes_surf=reshape(face_outer_surf,[],1);
        nodes_surf=unique(nodes_surf);
        
        % the following lines will determine the node locations of any
        % elements on the surfce if desired and the node locations are
        % given
        if nargin>1 && nargout>3
                nodes_outer_surf_coords=nodes(nodes_surf,:);
        end
end