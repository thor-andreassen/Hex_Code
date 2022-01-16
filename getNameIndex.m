function index=getNameIndex(data,name)
    index=1;
    endif=0;
    count=1;
    while endif==0 && count<=length(data)
       if testCharPresentInChar(char(data(count).name),name)
           endif=1;
           index=count;
       else
           count=count+1;
       end
    end
end