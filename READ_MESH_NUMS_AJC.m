function [nodelist,elemlist,elemlist_renum]=READ_MESH_NUMS_AJC(NME)
% [nodelist,elemlist,elemlist_renum]=READ_MESH_NUMS_AJC(NME)
% Extracts nodes and elements from a .inp file.
% INPUTS:   NME (string) - full file path for .inp file
%                        - example: 'C:/.../myfilename.inp'
%                        - nodes & elements must be separated by multiple asterisks
%                        - file must end with multiple asterisks
%
% OUTPUTS:  nodelist (double) - contains node numbers (first column) and associated
%              coordinates [N,4]
%           elemlist (double) - contains element numbers (first column) and
%              associated nodes
%           elemlist_renum (double) - contains renumbered node and element numbers
%              for use with MATLAB's patch command

[pathstr,name,ext] = fileparts(NME);
if isempty(ext)
    NME=[NME '.inp'];
end

fin=fopen(NME); %Open the .inp file
alldata=textscan(fin,'%s'); % Read in all data

%% Find the range of nodes
% Beginning
for i=1:length(alldata{1})
    if isempty(strfind(cell2mat(alldata{1}(i)),'*NODE'))==0
        snode=i+1;
        break
    end
end
% End
for i=snode+1:length(alldata{1})
    if isempty(strfind(cell2mat(alldata{1}(i)),'*'))==0
        enode=i-1;
        break
    end
end
%% Find the range of elements
% Beginning
for i=enode:length(alldata{1})
    if isempty(strfind(cell2mat(alldata{1}(i)),'*ELEMENT'))==0
        selem=i+1;
        if isempty(strfind(cell2mat(alldata{1}(selem-1)),'C3D8'))==0
            disp('C3D8 Hex mesh identified')
            meshtype=9;
        elseif isempty(strfind(cell2mat(alldata{1}(selem-1)),'R3D3'))==0
            disp('R3D3 Triangular mesh identified')
            meshtype=4;
        elseif isempty(strfind(cell2mat(alldata{1}(selem-1)),'C3D4'))==0
            disp('C3D4 Tet mesh identified')
            meshtype=5;
        elseif isempty(strfind(cell2mat(alldata{1}(selem-1)),'R3D4'))==0
            disp('R3D4 Quad mesh identified')
            meshtype=5;
        else
            return
        end
        break
    end
end
% End
for i=selem+1:length(alldata{1})
    if isempty(strfind(cell2mat(alldata{1}(i)),'*'))==0
        eelem=i-1;
        break
    end
end

%% Generate node list
row=1;col=1;
for i=snode:enode
    switch isempty(str2num(cell2mat(alldata{1}(i))))
        case 0
            nodelist(row,col)=[str2num(cell2mat(alldata{1}(i)))];
            switch rem(col,4)
                case 0
                    row=row+1;
                    col=1;
                otherwise
                    col=col+1;
            end
    end
end

%% Generate element list
row=1;col=1;
for i=selem:eelem
    switch isempty(str2num(cell2mat(alldata{1}(i))))
        case 0
            elemlist(row,col)=[str2num(cell2mat(alldata{1}(i)))];
            switch rem(col,meshtype)
                case 0
                    row=row+1;
                    col=1;
                otherwise
                    col=col+1;
            end
    end
end


[szn(1),szn(2)]=size(nodelist); %Find size of the node matrix
for m=1:szn(1) %Go node by node
    clear rp
    [rp(:,1),rp(:,2)]=find(elemlist==nodelist(m,1)); %Find references to specific node in the element matrix
    for n=1:size(rp(:,1)) %Loop to go through each occurance of the node reference
        elemlist_renum(rp(n,1),rp(n,2))=m; %Replace the node reference with the node index (line number) of that node definition in nds
    end
end
    
fclose(fin);
