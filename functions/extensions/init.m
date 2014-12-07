% Function init 
% initializes the IPL - INL interface searching for the dark to bright
% interface
function phi=init(V2,phi)


    ONH = zeros(size(V2));
    

    % search within the detected retina
    volume2 = or((phi(:,:,:,2)-23)<0, (phi(:,:,:,2)-20+phi(:,:,:,1)+5)>0);
    for i =1:size(V2,3)
       for j =1:size(V2,2)
           if nnz(volume2(:,j,i))>(size(volume2,1)-5)
               volume2(:,j,i) = 0;

           elseif j<size(V2,2)
               a = find(1-volume2(:,j,i),1,'first');
               b = find(1-volume2(:,j+1,i),1,'first');
               a1 = find(1-volume2(:,j,i),1,'last');
               b1 = find(1-volume2(:,j+1,i),1,'last');
               if a>b

                   if a>b1
                      volume2(:,j,i) = 0;
                      volume2(:,j+1,i) = 0;
                   end

               else
                  if b>a1
                      volume2(:,j,i) = 0;
                      volume2(:,j+1,i) = 0;

                  end
               end


           end

       end
    end
    counter =0;

    % initialization for every 10-th slice than interpolated inbetween
    image(:,:,1)= double(V2(:,:,1));
    % create nodes for the graph
    [E, N, index] = construct_graph(size(image,1),size(image,2)+2);
    for ind=[1:12:size(V2,3)]

        counter = counter+1;
        image(:,:,1)= double(V2(:,:,ind));
        % dijsktra shortest path
        [phi_tmp1(:,:,counter) cost aa] = minimal_test2(image, E, N,0,ONH(:,:,ind),0,volume2(:,:,ind));

        %            figure,imshow(log(image),[-9 0]), hold on, contour(phi_tmp1(:,:,counter),[0 0], 'r'),...
        %                 hold on, contour(isinf(cost)-0.5,[0 0], 'b'),...
        %                 hold off
        %             figure,imshow(cost,[]), hold on, contour(phi_tmp1(:,:,counter),[0 0], 'r'),hold off
        
        % transforms path to coordinates
        coor2(:,:,counter) = koordinate(phi_tmp1(:,:,counter));
    end

    % known points
    X = [1:12:size(V2,3)];

    % wanted points
    Xq = (1:size(V2,3));
    volume = zeros(size(V2));
    for i =1:size(V2,2)
        % interpolation
        V = squeeze(coor2(1,i,:))';
        Vq = interp1(X,V,Xq,'spline');
        options.line = [Vq; Xq]';
        volume(:,i,:) = -compute_levelset('horizontal2',size(volume,1),size(volume,3),options);

    end
    phi_test(:,:,:,1) = volume;

    clear E N V Vq X Xq Y aa ans coor coor2 cost dest e2
    clear force height i image ind index init options p2 phi phi_bocni phi tmp phi_tmp1
    clear width x y e1 p1 phi_tmp v volume volume2
    phi = phi_test;
end


