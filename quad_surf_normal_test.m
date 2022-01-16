%% clearing
clear
close all
clc

%% symbolics
syms xsi eta
vals=[-1,-1;1,-1;1,1,;-1,1];
for count_node=1:4
        shape_funcs(count_node,1)=(1/4)*(1+vals(count_node,1)*xsi)*(1+vals(count_node,2)*eta);
end

shape_funcs_num=matlabFunction(shape_funcs,'Vars',{[xsi;eta]});

x=sym('x',[4 1],'real');
y=sym('y',[4 1],'real');
z=sym('z',[4 1],'real');

mat=[x(1), x(2), x(3),x(4);
        y(1), y(2), y(3),y(4);
        z(1), z(2), z(3),z(4);];

project_point=mat*shape_funcs;
project_point_num=matlabFunction(project_point,'Vars',{x,y,z,[xsi;eta]});
project_grad=jacobian(project_point,[xsi eta]);

P_q=sym('P_q',[3 1],'real');
dist_func=norm(P_q-project_point);
grad_func=jacobian(dist_func,[xsi,eta]);
hess_func=hessian(dist_func,[xsi,eta]);

dist_func_num=matlabFunction(dist_func,'Vars',{x,y,z,P_q,[xsi;eta]});
dist_grad_num=matlabFunction(grad_func,'Vars',{x,y,z,P_q,[xsi;eta]});
dist_hess_num=matlabFunction(hess_func,'Vars',{x,y,z,P_q,[xsi;eta]});

mat_inv=pinv(mat);
mat_inv_num=matlabFunction(mat_inv,'vars',{x,y,z});
%% determine xsi eta for new point
x_elem=[0;10;10;0];
y_elem=[0;0;10;10];
z_elem=[0;0;0;5];

xq=5;
yq=0.5;
zq=-.25;
query_point_real=[xq,yq,zq]';

hold on
plot3(xq,yq,zq,'bo');

optim_nat=[0.5;0.5];

test_func=@(nat)getFuncGradHesForQ4(x_elem,y_elem,z_elem,query_point_real,nat);
 

real_coordinate=@(nat) project_point_num(x_elem,y_elem,z_elem,nat);
% dist_func=@(nat)norm(query_point_real-real_coordinate(nat));
% [optim_nat_1,optim_dist,exitflag,output,lambda,grad,hessian]=fmincon(dist_func,optim_nat);

options = optimoptions('fmincon','Algorithm','interior-point',...
    'SpecifyObjectiveGradient',true);
optim_nat=[0.1;0.5];
[optim_nat,optim_dist,exitflag,output,lambda,grad,hessian]=fmincon(test_func,optim_nat,[],[],[],[],[-1,-1],[1,1],[],options)

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

optim_real=real_coordinate(optim_nat)
plot3(optim_real(1),optim_real(2),optim_real(3),'bx');
axis equal

