function [projection_pt,surf_to_pt_normal,point_to_surf_distance,projection_nat]=getNearestPointToQ4(x,y,z,query_pt,show_plot)
        %% Function to calculate the nearest point between a query point and a Q4 Mesh Element
        % This function takes in the x, y, z coordinates of the edges nodes
        % of a Q4 element, and the x,y,z coordinate of a query point and
        % determines the nearest point on the Q4 element.
        %
        % Inputs:
                % x: array of x coordinates(4 x 1) of q4 mesh element
                % y: array of y coordinates(4 x 1) of q4 mesh element
                % z: array of z coordinates(4 x 1) of q4 mesh element
                % query_pt:  x,y,z coordinate (1 x 3) of point to find nearest point
                % show plot: 1 or 0 based on whether the plot of the projection is
                % desired to be seen
        %
        % Outputs:
                % projection_pt: Cartesian Coordinates (x, y, z) of nearest point on q4 element to query point
                % surf_to_pt_normal: Cartesian normalized vector point from projection point to query point
                % surf_to_pt_normal: Cartesian normalized vector point from projection point to query point
                % point_to_surf_distance: Distance from point to q4 element. The
                        % distance is positive, if the element normal is acute to the
                        % surface to point normal (outside). The distance is negative if the element
                        % normal is obtuse to the surface to point normal (inside)
                % projection_nat: xsi and eta natrual coordinates of the projection
                        % point in the Q4 element
                
        % the following initializes the search at the "center" of the
        % element.
        projection_nat=[0.5;0.5];
        
        % the following line creates a function handle to calculate the
        % distance and gradient of the distance between the element
        % projection point, and the query point. This distance function is
        % what the function minimizes to calculate the normal between the
        % surface and the query point, which is the smallest distance
        % between the querry point and the Q4 element. The other function
        % handle is the for hessian of the function and the constraint
        % equation. However, for this simple case the hessian of the
        % constrain is zero since no constraints are present.
        test_func=@(nat)getFuncGradHesForQ4(x,y,z,query_pt,nat);
        hess_handle=@(nat,lambda) getHessForQ4(x,y,z,query_pt,nat,lambda);
        
        % the following lines define the optimization to find the minimum
        % distance between the element and the query point
        options = optimoptions('fmincon','Algorithm','interior-point',...
                'SpecifyObjectiveGradient',true,'Display','off',...
                'HessianFcn',hess_handle);
        [projection_nat,point_to_surf_distance]=fmincon(test_func,projection_nat,[],[],[],[],[-1,-1],[1,1],[],options);
        
        % the following line calculates the location of the projection
        % point based on the calculated optimimum natural coordinate
        % location
        projection_pt=getQ4PointFromNat(x,y,z,projection_nat);
        
        % the following line calculates the normal vector from the q4 element to
        % the query point.
        surf_to_pt_normal=(query_pt-projection_pt)/norm(query_pt-projection_pt);
        
        % the following loop is used to plot the element surface, the query
        % point and the projection point if desired.
        if show_plot
                real_coordinate=@(nat) getQ4PointFromNat(x,y,z,nat);
                xsi_range=-1:.1:1;
                eta_range=-1:.1:1;
                surf_val=zeros(length(xsi_range)*length(eta_range),3);
                counter=1;
                for countxsi=xsi_range
                        for counteta=eta_range
                                current_nat=[countxsi;counteta];
                                surf_val(counter,:)=real_coordinate(current_nat);
                                counter=counter+1;
                        end
                end
                plot3(surf_val(:,1),surf_val(:,2),surf_val(:,3),'rx');
                hold on
                plot3(projection_pt(1),projection_pt(2),projection_pt(3),'bx');
                plot3(query_pt(1),query_pt(2),query_pt(3),'bo');
                axis equal
        end
        
        % the following lines calculate an approximate normal direction at
        % each of the nodes of the original element, as the cross product
        % of the vector to its nearest 2 neighbors for each node of the Q4
        % element
        vec1=[x(2)-x(1),y(2)-y(1),z(2)-z(1)];
        vec2=[x(4)-x(1),y(4)-y(1),z(4)-z(1)];
        pt1_approx_normal=cross(vec1,vec2)/norm(cross(vec1,vec2));

        vec1=[x(3)-x(2),y(3)-y(2),z(3)-z(2)];
        vec2=[x(1)-x(2),y(1)-y(2),z(1)-z(2)];
        pt2_approx_normal=cross(vec1,vec2)/norm(cross(vec1,vec2));

        vec1=[x(4)-x(3),y(4)-y(3),z(4)-z(3)];
        vec2=[x(2)-x(3),y(2)-y(3),z(2)-z(3)];
        pt3_approx_normal=cross(vec1,vec2)/norm(cross(vec1,vec2));

        vec1=[x(1)-x(4),y(1)-y(4),z(1)-z(4)];
        vec2=[x(3)-x(4),y(3)-y(4),z(3)-z(4)];
        pt4_approx_normal=cross(vec1,vec2)/norm(cross(vec1,vec2));

        % the following line calculates the average normal direction of the
        % element, as the average of the other normals.
        average_normal=mean([pt1_approx_normal;pt2_approx_normal;...
                pt3_approx_normal;pt4_approx_normal]);
        average_normal=average_normal/norm(average_normal);
        
        % the following line is used to determine if the distance should be
        % negative or positive based on which "side" of the element the
        % query point is.
        if dot(surf_to_pt_normal,average_normal) < 0
                point_to_surf_distance=-point_to_surf_distance;
        end
end

function project_point = getQ4PointFromNat(x,y,z,nat)
        % this function takes in x, y z coordinates for a Q4 element, and
        % then natural coordinates for a query point, and determines its
        % locations in the original cartesian coordinates for the element.
        eta = nat(2,:);
        x1 = x(1,:);
        x2 = x(2,:);
        x3 = x(3,:);
        x4 = x(4,:);
        xsi = nat(1,:);
        y1 = y(1,:);
        y2 = y(2,:);
        y3 = y(3,:);
        y4 = y(4,:);
        z1 = z(1,:);
        z2 = z(2,:);
        z3 = z(3,:);
        z4 = z(4,:);
        t2 = eta+1.0;
        t3 = eta-1.0;
        t4 = xsi./4.0;
        t5 = t4+1.0./4.0;
        t6 = t4-1.0./4.0;
        project_point = [t2.*t5.*x3-t3.*t5.*x2+t3.*t6.*x1-t2.*t6.*x4;t2.*t5.*y3-t3.*t5.*y2+t3.*t6.*y1-t2.*t6.*y4;t2.*t5.*z3-t3.*t5.*z2+t3.*t6.*z1-t2.*t6.*z4];
end


function [dist_func,grad_func]=getFuncGradHesForQ4(x,y,z,pt_q,nat)
        % This function returns the distance and gradient of a set of
        % poitns for a Q4 element for x, y, z coordinates, to a query point
        % based on the projection point based on natural coordinates. This
        % returns the distance between the projection point and the query
        % point.
        P_q1 = pt_q(1,:);
        P_q2 = pt_q(2,:);
        P_q3 = pt_q(3,:);
        eta = nat(2,:);
        x1 = x(1,:);
        x2 = x(2,:);
        x3 = x(3,:);
        x4 = x(4,:);
        xsi = nat(1,:);
        y1 = y(1,:);
        y2 = y(2,:);
        y3 = y(3,:);
        y4 = y(4,:);
        z1 = z(1,:);
        z2 = z(2,:);
        z3 = z(3,:);
        z4 = z(4,:);
        t2 = eta+1.0;
        t3 = eta-1.0;
        t4 = xsi./4.0;
        t5 = t4+1.0./4.0;
        t6 = t4-1.0./4.0;
        dist_func = sqrt(abs(P_q1-t2.*t5.*x3+t3.*t5.*x2-t3.*t6.*x1+t2.*t6.*x4).^2+abs(P_q2-t2.*t5.*y3+t3.*t5.*y2-t3.*t6.*y1+t2.*t6.*y4).^2+abs(P_q3-t2.*t5.*z3+t3.*t5.*z2-t3.*t6.*z1+t2.*t6.*z4).^2);

        P_q1 = pt_q(1,:);
        P_q2 = pt_q(2,:);
        P_q3 = pt_q(3,:);
        eta = nat(2,:);
        x1 = x(1,:);
        x2 = x(2,:);
        x3 = x(3,:);
        x4 = x(4,:);
        xsi = nat(1,:);
        y1 = y(1,:);
        y2 = y(2,:);
        y3 = y(3,:);
        y4 = y(4,:);
        z1 = z(1,:);
        z2 = z(2,:);
        z3 = z(3,:);
        z4 = z(4,:);
        t2 = eta+1.0;
        t3 = eta-1.0;
        t4 = xsi./4.0;
        t5 = t4+1.0./4.0;
        t6 = t4-1.0./4.0;
        t7 = t2.*t5.*x3;
        t8 = t2.*t5.*y3;
        t9 = t2.*t5.*z3;
        t10 = t3.*t5.*x2;
        t11 = t2.*t6.*x4;
        t12 = t3.*t5.*y2;
        t13 = t2.*t6.*y4;
        t14 = t3.*t5.*z2;
        t15 = t2.*t6.*z4;
        t16 = t3.*t6.*x1;
        t18 = t3.*t6.*y1;
        t20 = t3.*t6.*z1;
        t17 = -t7;
        t19 = -t8;
        t21 = -t9;
        t22 = -t16;
        t23 = -t18;
        t24 = -t20;
        t25 = P_q2+t12+t13+t19+t23;
        t26 = P_q3+t14+t15+t21+t24;
        t27 = P_q1+t10+t11+t17+t22;
        t28 = abs(t27);
        t29 = abs(t25);
        t30 = abs(t26);
        t31 = sign(t27);
        t32 = sign(t25);
        t33 = sign(t26);
        t34 = t28.^2;
        t35 = t29.^2;
        t36 = t30.^2;
        t37 = t34+t35+t36;
        t38 = 1.0./sqrt(t37);
        grad_func = [t38.*(t28.*t31.*((t3.*x1)./4.0+(t2.*x3)./4.0-(t3.*x2)./4.0-(t2.*x4)./4.0).*2.0+t29.*t32.*((t3.*y1)./4.0+(t2.*y3)./4.0-(t3.*y2)./4.0-(t2.*y4)./4.0).*2.0+t30.*t33.*((t3.*z1)./4.0+(t2.*z3)./4.0-(t3.*z2)./4.0-(t2.*z4)./4.0).*2.0).*(-1.0./2.0),(t38.*(t28.*t31.*(t5.*x2-t6.*x1-t5.*x3+t6.*x4).*2.0+t29.*t32.*(t5.*y2-t6.*y1-t5.*y3+t6.*y4).*2.0+t30.*t33.*(t5.*z2-t6.*z1-t5.*z3+t6.*z4).*2.0))./2.0];
end

function hess_func=getHessForQ4(x,y,z,pt_q,nat,lambda)
        % This function returns the hessian of a set of
        % poitns for a Q4 element for x, y, z coordinates, to a query point
        % based on the projection point based on natural coordinates. This
        % returns the distance between the projection point and the query
        % point. Lambda is not used since no non-linear constraint is
        % present, but the optimization function needs it to be able to
        % solve
        P_q1 = pt_q(1,:);
        P_q2 = pt_q(2,:);
        P_q3 = pt_q(3,:);
        eta = nat(2,:);
        x1 = x(1,:);
        x2 = x(2,:);
        x3 = x(3,:);
        x4 = x(4,:);
        xsi = nat(1,:);
        y1 = y(1,:);
        y2 = y(2,:);
        y3 = y(3,:);
        y4 = y(4,:);
        z1 = z(1,:);
        z2 = z(2,:);
        z3 = z(3,:);
        z4 = z(4,:);
        t2 = eta+1.0;
        t3 = eta-1.0;
        t4 = x1./4.0;
        t5 = x2./4.0;
        t6 = x3./4.0;
        t7 = x4./4.0;
        t8 = xsi./4.0;
        t9 = y1./4.0;
        t10 = y2./4.0;
        t11 = y3./4.0;
        t12 = y4./4.0;
        t13 = z1./4.0;
        t14 = z2./4.0;
        t15 = z3./4.0;
        t16 = z4./4.0;
        t17 = -t5;
        t18 = -t7;
        t19 = -t10;
        t20 = -t12;
        t21 = -t14;
        t22 = -t16;
        t23 = t2.*t6;
        t24 = t2.*t7;
        t25 = t2.*t11;
        t26 = t2.*t12;
        t27 = t2.*t15;
        t28 = t2.*t16;
        t29 = t8+1.0./4.0;
        t30 = t3.*t4;
        t31 = t3.*t5;
        t32 = t2.*x4.*(-1.0./4.0);
        t33 = t3.*t9;
        t34 = t3.*t10;
        t35 = t2.*y4.*(-1.0./4.0);
        t36 = t3.*t13;
        t37 = t3.*t14;
        t38 = t2.*z4.*(-1.0./4.0);
        t39 = t8-1.0./4.0;
        t40 = t3.*x2.*(-1.0./4.0);
        t41 = t3.*y2.*(-1.0./4.0);
        t42 = t3.*z2.*(-1.0./4.0);
        t43 = t29.*x2;
        t44 = t29.*x3;
        t45 = t29.*y2;
        t46 = t29.*y3;
        t47 = t29.*z2;
        t48 = t29.*z3;
        t49 = t39.*x1;
        t50 = t39.*x4;
        t51 = t39.*y1;
        t52 = t39.*y4;
        t53 = t39.*z1;
        t54 = t39.*z4;
        t79 = t4+t6+t17+t18;
        t80 = t9+t11+t19+t20;
        t81 = t13+t15+t21+t22;
        t82 = t23+t30+t32+t40;
        t83 = t25+t33+t35+t41;
        t84 = t27+t36+t38+t42;
        t55 = -t43;
        t56 = -t45;
        t57 = -t47;
        t58 = -t50;
        t59 = -t52;
        t60 = -t54;
        t61 = t2.*t44;
        t62 = t2.*t46;
        t63 = t2.*t48;
        t64 = t3.*t43;
        t65 = t2.*t50;
        t66 = t3.*t45;
        t67 = t2.*t52;
        t68 = t3.*t47;
        t69 = t2.*t54;
        t70 = t3.*t49;
        t72 = t3.*t51;
        t74 = t3.*t53;
        t85 = t82.^2;
        t86 = t83.^2;
        t87 = t84.^2;
        t91 = (t47-t48-t53+t54).^2;
        t92 = (t43-t44-t49+t50).^2;
        t93 = (t45-t46-t51+t52).^2;
        t71 = -t61;
        t73 = -t62;
        t75 = -t63;
        t76 = -t70;
        t77 = -t72;
        t78 = -t74;
        t88 = t44+t49+t55+t58;
        t89 = t46+t51+t56+t59;
        t90 = t48+t53+t57+t60;
        t94 = P_q2+t66+t67+t73+t77;
        t95 = P_q3+t68+t69+t75+t78;
        t96 = P_q1+t64+t65+t71+t76;
        t97 = abs(t96);
        t98 = dirac(t96);
        t99 = abs(t94);
        t100 = dirac(t94);
        t101 = abs(t95);
        t102 = dirac(t95);
        t103 = sign(t96);
        t104 = sign(t94);
        t105 = sign(t95);
        t106 = t97.^2;
        t107 = t99.^2;
        t108 = t101.^2;
        t109 = t103.^2;
        t110 = t104.^2;
        t111 = t105.^2;
        t112 = t81.*t101.*t105.*2.0;
        t116 = t79.*t97.*t103.*2.0;
        t117 = t80.*t99.*t104.*2.0;
        t121 = t82.*t97.*t103.*2.0;
        t122 = t83.*t99.*t104.*2.0;
        t123 = t84.*t101.*t105.*2.0;
        t124 = t97.*t103.*(t43-t44-t49+t50).*-2.0;
        t125 = t99.*t104.*(t45-t46-t51+t52).*-2.0;
        t126 = t101.*t105.*(t47-t48-t53+t54).*-2.0;
        t130 = t82.*t97.*t98.*(t43-t44-t49+t50).*-4.0;
        t131 = t83.*t99.*t100.*(t45-t46-t51+t52).*-4.0;
        t132 = t84.*t101.*t102.*(t47-t48-t53+t54).*-4.0;
        t113 = t82.*t109.*(t43-t44-t49+t50).*-2.0;
        t114 = t83.*t110.*(t45-t46-t51+t52).*-2.0;
        t115 = t84.*t111.*(t47-t48-t53+t54).*-2.0;
        t118 = -t112;
        t119 = -t116;
        t120 = -t117;
        t127 = t106+t107+t108;
        t133 = t121+t122+t123;
        t134 = t124+t125+t126;
        t128 = 1.0./sqrt(t127);
        t137 = t113+t114+t115+t118+t119+t120+t130+t131+t132;
        t129 = t128.^3;
        t138 = t128.*(t112+t116+t117+t82.*t109.*(t43-t44-t49+t50).*2.0+t83.*t110.*(t45-t46-t51+t52).*2.0+t84.*t111.*(t47-t48-t53+t54).*2.0+t82.*t97.*t98.*(t43-t44-t49+t50).*4.0+t83.*t99.*t100.*(t45-t46-t51+t52).*4.0+t84.*t101.*t102.*(t47-t48-t53+t54).*4.0).*(-1.0./2.0);
        t135 = t129.*t133.*(t97.*t103.*(t43-t44-t49+t50).*2.0+t99.*t104.*(t45-t46-t51+t52).*2.0+t101.*t105.*(t47-t48-t53+t54).*2.0).*(-1.0./4.0);
        t136 = (t129.*t133.*(t97.*t103.*(t43-t44-t49+t50).*2.0+t99.*t104.*(t45-t46-t51+t52).*2.0+t101.*t105.*(t47-t48-t53+t54).*2.0))./4.0;
        t139 = t136+t138;
        hess_func = reshape([(t128.*(t85.*t109.*2.0+t86.*t110.*2.0+t87.*t111.*2.0+t85.*t97.*t98.*4.0+t86.*t99.*t100.*4.0+t87.*t101.*t102.*4.0))./2.0-(t129.*t133.^2)./4.0,t139,t139,t129.*(t97.*t103.*(t43-t44-t49+t50).*2.0+t99.*t104.*(t45-t46-t51+t52).*2.0+t101.*t105.*(t47-t48-t53+t54).*2.0).^2.*(-1.0./4.0)+(t128.*(t92.*t109.*2.0+t91.*t111.*2.0+t93.*t110.*2.0+t92.*t97.*t98.*4.0+t93.*t99.*t100.*4.0+t91.*t101.*t102.*4.0))./2.0],[2,2]);
end

