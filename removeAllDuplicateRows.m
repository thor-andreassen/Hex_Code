function [A,removed_index_A]=removeAllDuplicateRows(A)
% the following function removes all rows of A with multiple instances. So
% as to only leave rows with entirely unique rows that do not appear
% anywhere else. The removed index is the location of all instances in A
% that need to be removed as they have copies.
        [B,removed_indexes] = sortrows(A);
        f = find(diff([false;all(diff(B,1,1)==0,2);false])~=0);
        s = ones(length(f)/2,1);
        f1 = f(1:2:end-1); f2 = f(2:2:end);
        t = cumsum(accumarray([f1;f2+1],[s;-s],[size(B,1)+1,1]));
        removed_index_A=removed_indexes(t(1:end-1)>0);
        A(removed_indexes(t(1:end-1)>0),:) = [];
end