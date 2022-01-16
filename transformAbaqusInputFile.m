function [nodes,trans_nodes,elements,transmat]=transformAbaqusInputFile(abaqus_input_name,transform_mat,abaqus_output_name)
% This code can be used to output a transformed Abaqus input file for a
% set of nodes and elements, given the old Abaqus input file with the nodes
% and elements listed, and the corresponding transformation matrix that you
% wish to apply to the data. abaqus_input_name is the abauqs input file
% name location, and transform_mat is the tranformation matrix to apply to
% the nodes.
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


%% Transform Data

transmat=transform_mat;
trans_nodes=transformCoord(nodes,transmat);
trans_nodes=[nodes(:,1),trans_nodes];


%% Output files
out_file=abaqus_output_name;
fid=fopen(out_file,'w');
for counti=1:(N_start-1)
    fprintf(fid,'%s\n',char(S(counti)));
end

for counti=1:size(trans_nodes,1)
    fprintf(fid,'%6.12g,   ',trans_nodes(counti,1:(end-1)));
    fprintf(fid,'%6.12g\n',trans_nodes(counti,end));
end

for counti=(N_end+1):length(S)
    fprintf(fid,'%s\n',char(S(counti)));
end
end