function [dist,intersect_point]=getShortestPointToSegment(point,segment1,segment2)
        vec1=segment2-segment1;
        vec1=vec1/norm(vec1);
        start_to_point_vec=point-segment1;
        start_to_point_vec_unit=start_to_point_vec/norm(start_to_point_vec);
        vec3=cross(vec1,start_to_point_vec_unit);
        vec3=vec3/norm(vec3);
        norm_dir=cross(vec3,vec1);
        norm_dir=norm_dir/norm(norm_dir);
        dist=dot(start_to_point_vec,norm_dir);
        intersect_point=point-dist*(norm_dir);
end