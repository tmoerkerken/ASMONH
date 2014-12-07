% function MINIMAL PATH 
% finds IPL - INL interface using Dijsktra minimal path on the dark to bright
% gradient in y direction

function [phi cost coor] = minimal_test2 (image, E, N, force,ONH,ind,volume)


    image(image>1) = 0.001;
    % gradient in y direction (strong transitions in intensity between 
    % layers will have high values)
    Gy = im2mat(dy(image,3));
    init = 1;
    dest = (size(image,2)-1+2)*size(image,1)+1;
    % change strong transitions to have low values for minimal path
    Gy = 1 - Gy./max(Gy(:));

    % everything that's not inside retina has an Inf values, only seaching
    % for the path inbetween retina
    Gy(volume==1) = Inf;
    Gy(ONH==1) = 10^-10;

    % no initial points were selected, but virtual column added on each
    % side of image with low values
    cost = 10^-10*ones(size(Gy,1),size(Gy,2)+2);
    cost(:,2:end-1) = Gy;
    cost(isnan(cost)) = 1;

    % relating nodes vith the cost 
    for i = 1:size(E,1)
        V(i) = cost(E(i,2));
    end

    V = V';
    % creates sparse matrix of costs for dijsktra
    A = sparse(E(:,1),E(:,2),V,N,N,8*N);

    % finds the shortest path in graph
    [dist, path, pred]=graphshortestpath(A,init,dest);
    
    % retrieve the path
    la  = zeros(size(image,1),size(image,2)+2);
    for i =1:size(path,2)
        la(path(i))=1;
    end    

    rnfl = la(:,2:end-1);
    % find coordinates of the path
    for i=1:size(image,2)

    if isempty(find(rnfl(:,i),1,'first'))
        if i==1
            coor(1,i) = find(rnfl(:,2),1,'first');
        else
            coor(1,i) = coor(1,i-1);
        end
    else
        coor(1,i) = find(rnfl(:,i),1,'first');
    end
    coor(2,i) =i;
    end
    options.line = coor';
    % creates a singed distance function from the coordinates of the
    % interface
    phi = -compute_levelset('horizontal2',size(image,1),size(image,2),options);

end