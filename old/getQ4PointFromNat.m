function project_point = getQ4PointFromNat(x,y,z,nat)
        %GETQ4POINTFROMNAT
        %    PROJECT_POINT = GETQ4POINTFROMNAT(IN1,IN2,IN3,IN4)

        %    This function was generated by the Symbolic Math Toolbox version 8.3.
        %    06-Jan-2022 15:11:09

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