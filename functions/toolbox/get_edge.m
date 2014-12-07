% GET_EDGE returns the edge of an area
% in a one dimensional vector


function x = get_edge(area,mode)
clear x; 
    x = zeros(1,size(area,2));
    for i = 1:size(area,2)

        tmp = find(area(:,i)==0,1,mode);
        if isempty(tmp)==1
            [x(1,i)] = 0;
        else
            [x(1,i)] = tmp;
        end
    end
end

