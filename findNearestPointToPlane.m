function [distance,projected_pt]=findNearestPointToPlane(query_pt,plane_normal_vec,plane_pt)
        temp_vec=query_pt-plane_pt;
        distance=dot(temp_vec,plane_normal_vec);
        projected_pt=query_pt-(distance*plane_normal_vec);
end