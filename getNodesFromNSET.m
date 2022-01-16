function nodes=getNodesFromNSET(NSET_sets,NSET_nodes,name)
    current_nset_index=getNameIndex(NSET_sets,name);
    nodes=findNodesCoordinates(NSET_nodes,NSET_sets(current_nset_index).nodes);
end
    
