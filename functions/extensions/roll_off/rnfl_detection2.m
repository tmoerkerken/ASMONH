    
function vitreous = rnfl_detection2(V2,V,miss)



    counter = 0;
    for i=[1:10:size(V2,3),size(V2,3)]
        counter  = counter+1;
        for j=1:size(V2,1)  
            signal = smooth(V(:,j,i), 10);
            [pks,locs] = findpeaks(signal,'npeaks',1,'MINPEAKHEIGHT',0.01);
            if isempty(locs)
                if j>1 && j~=512
                    coor2(1,j,counter) = coor2(1,j-1,counter);
                    coor2(2,j,counter) = j;
                else
                    coor2(1,j,counter) = size(V,1)/2;
                    coor2(2,j,counter) = j;
                end
                %             [pks,locs] = findpeaks(signal,'npeaks',1,'threshold',10^-4);
                else
                    coor2(1,j,counter) = locs;
                    coor2(2,j,counter) = j;
            end

        end
        coor2(1,:,counter) = smooth(coor2(1,:,counter),0.1,'loess');
    end

    X = [1:10:size(V2,3), size(V2,3)];

    % wanted points
    Xq = (1:size(V2,3));
    volume = zeros(size(V));
    for i =1:size(V,2)
    % spline interpolation
        V1 = squeeze(coor2(1,i,:))';
        Vq = interp1(X,V1,Xq,'spline');
        options.line = [Vq; Xq]';
        volume(:,i,:) = -compute_levelset('horizontal2',size(volume,1),size(volume,3),options);

    end


    %run('C:\Program Files\DIPimage 2.4.1\dipstart')
%    phi=initial_retina((V),(volume+7)<0,zeros(size(V)));
	phi = volume;
    
%    for i =1:2:37
%        figure,imshow(log(V(:,:,i)),[-9 0]), hold on,
%        contour(phi(:,:,i),[0 0],'r'),...
%           hold on, contour(volume(:,:,i)+7,[0 0],'b')
%    end
%     
    vitreous = V;
    vitreous((phi-20)<0) = NaN; vitreous(miss==1) = NaN; vitreous(vitreous==0) = NaN; 
end