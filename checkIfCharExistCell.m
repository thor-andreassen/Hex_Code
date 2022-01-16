function result=checkIfCharExistCell(input_char,cell_array)

result=0;
count=1;
end_check=0;
while count<=length(cell_array) && end_check==0
    if testCharPresentInChar(input_char,char(cell_array(count)),0)
        end_check=1;
        result=1;
    else
        count=count+1;
    end
    
end

