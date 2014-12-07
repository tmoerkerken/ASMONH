function [multi] = postcontour(phi)
tmp = 0;
keyboard
multi = zeros(10,size(phi,2));
    for i=1:size(phi,3)
        for j=1:size(phi,2)
            tmp = phi(:,j,i);   
            tmp = find(edge(tmp==1));
            d = size(tmp,1);
            multi(1:d,j) = tmp(:);
        end
    end
    
end