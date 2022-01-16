function [nodes,nset]=readAbaqusNSET(filename)
%% Code to get the NSETs in an Abaqus .inp file

% Written by Thor Andreassen
% 7/24/19


% This code will go through and determine all of the nodes (coordinates)
% required for the nodesets, as well as return the Node sets themselves in
% an Abaqus input file. It will arrange the NSETs into a structure array,
% that contains the names of all the NSETs, the nodes within each of those
% sets, and a separate output with the nodes. This should look through the
% entire Abaqus input file, and find all NSETs, regardless of there
% location. NOTE: the nodes for these Nodesets, must be contained in a
% *NODE card in the file somewhere.

    fname = filename;
    fid = fopen(fname,'rt') ;
    S = textscan(fid,'%s','Delimiter','\n');
    %% Find NODES

    S=S{1};
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

    %% GET NSETS
    counti=1;
    startNSETS=[];
    while counti<=length(S)
        if ~isempty(strfind(lower(char(S(counti))),'*nset'))
            startNSETS=[startNSETS counti];

        end
        counti=counti+1;
    end
    
    endNSETS=[];
    for counter=(startNSETS+1)
        counti=counter;
        endcount=0;
        while counti<=length(S) &&endcount==0
            if ~isempty(strfind(lower(char(S(counti))),'*'))
            endNSETS=[endNSETS, counti];
            endcount=1;
            end
            counti=counti+1;
        end
    end
        
    
    if length(endNSETS)<length(startNSETS)
        endNSETS=[endNSETS, length(S)+1];
    end

    endNSETS=endNSETS-1;
    
   %% Get NSET Names
   count=1;
   for counti=startNSETS
       tempstring=char(S(counti));
       start_name_index=1;
       end_name_index=length(tempstring);
       for countj=1:length(tempstring)
           
           if tempstring(countj)=='='
               start_name_index=countj+1;
               break
           end
       end
       
        for countj=start_name_index:length(tempstring)
           
           if tempstring(countj)==','
               end_name_index=countj-1;
               break
           end
        end
       nset_names{count}=tempstring(start_name_index:end_name_index);
       count=count+1;
        
        
   end
    
   %% Create Node SETS
   temp_data=[];
   for counti=1:length(startNSETS)
       count=1;
       temp_data=[];
       for countj=(startNSETS(counti)+1):(endNSETS(counti))
         temp_val=str2double(strsplit(char(S(countj)),','));
         for countk=length(temp_val):-1:1
             if isnan(temp_val(countk))
                 temp_val(countk)=[];
             end
         end
         temp_data=[temp_data temp_val];
       end
       count=count+1;
       nset(counti).name=char(nset_names(counti));
       nset(counti).nodes=temp_data(:,:);
   end
   
end
