function [nodes,elements,ptcloud]=readAbaqusInputFile(abaqus_input_name)
%% Code to read the nodes, and elements in an abaqus input file
% Written by Thor Andreassen
% 7/1/19

% This code can be used to gather the nodes and elements associated with an
% abaqus input file (.inp). The output are the "nodes" with the first
% collumn representing the node number and the remaining collumns
% representing the X,Y, Z coordinates. Each new row is a new node.
% The "elements" with the first collumn representing the element number
% and the remaining collumns are the nodes associated with that element.
% each new row represents an additional element. Lastly the "ptcloud" where
% the first collumn of the nodes has been striken to only return the
% coordinates associated with each node, and not the numbers.
fname = abaqus_input_name;
fid = fopen(fname,'rt') ;
S = textscan(fid,'%s','Delimiter','\n');
S=S{1};



%% Find Node Location Lines
N_start=1;
counti=1;
e_end=1;
while counti<=length(S) && e_end
    if ~isempty(strfind(lower(char(S(counti))),'*node'))
        N_start=counti;
        e_end=0;
        
    end
    counti=counti+1;
end

N_end=N_start;
counti=N_start+1;
e_end=1;
while counti<=length(S) && e_end
    if ~isempty(strfind(lower(char(S(counti))),'*'))
        N_end=counti;
        e_end=0;
        
    end
    counti=counti+1;
end

N_end=N_end-1;
N_start=N_start+1;

%% Get Nodes

temp=strsplit(char(S(N_start)));
for counti=length(temp):-1:1
    if isnan(str2double(temp(counti)))
        temp(counti)=[];
    end
end
n_length=length(temp);
nodes=zeros((N_end-N_start),n_length);
count=1;
for counti=N_start:N_end
    nodes(count,:)=str2double(strsplit(char(S(counti)),','));
    count=count+1;
end




%% Elements Index
E_start=N_end;
counti=N_end;
e_end=1;
while counti<=length(S) && e_end
    if ~isempty(strfind(lower(char(S(counti))),'*element'))
        E_start=counti;
        e_end=0;
        
    end
    counti=counti+1;
end

E_end=E_start;
counti=E_start+1;
e_end=1;
while counti<=length(S) && e_end
    if ~isempty(strfind(lower(char(S(counti))),'*'))
        E_end=counti;
        e_end=0;
        
    end
    counti=counti+1;
end
E_end=counti;

E_end=E_end-2;
E_start=E_start+1;

%% Get Elements


temp=strsplit(char(S(E_start)));
for counti=length(temp):-1:1
    if isnan(str2double(temp(counti)))
        temp(counti)=[];
    end
end

e_length=length(temp);
elements=zeros((E_end-E_start),e_length);
count=1;
for counti=E_start:E_end
    elements(count,:)=str2double(strsplit(char(S(counti)),','));
    count=count+1;
end

ptcloud=nodes(:,2:end);