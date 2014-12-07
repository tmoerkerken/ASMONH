% Function koordinate
% find xy coordinates of an edge in the image to be used for the creation
% of the signed level ser function

function coor = koordinate(phi)
rnfl = edge(phi>0,'canny');


    for i=1:size(rnfl,2)

        if isempty(find(rnfl(:,i),1,'first'))
            if i==1
                k=1;
                while(isempty(find(rnfl(:,k),1,'first')))
                    k=k+1;
                end
                coor(1,i) = find(rnfl(:,k),1,'first');
            else
                coor(1,i) = coor(1,i-1);
            end
        else
            coor(1,i) = find(rnfl(:,i),1,'first');
        end
        coor(2,i) =i;
    end
end