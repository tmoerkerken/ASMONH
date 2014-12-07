% INITIAL_RETINA

function phi = initial_retina(V2,miss,filename,path,output_folder,folder_name, int)


    V = V2;
    V(miss==1) = 1;
    image(:,:,1)= double(V2(:,:,1));

    counter = 0;
    
    for ind=[10:1:170, size(V2,3)]

        counter = counter+1;
        image(:,:,1)= double(V2(:,:,ind));
        image(image>1) = 10^-6;
        image(isnan(image)) = 1 ;
        image(image==Inf) = 0;
        image_after(:,:,counter) = image;        
        [phi(:,:,counter)] = rnfl_segmentation(image.^0.25, counter, int);

    end
    
    save(strcat(path,[output_folder],'\',[num2str(int,'%10.3f\n') '_' filename(1:end-4)],'_segment_RNFL.mat'),'phi','image_after');
  
	close all
    clear V Vq X Xq Y aa ans coor coor2 cost dest e2
    clear force height i image ind index init options p2 phi phi_bocni phi tmp phi_tmp1
    clear width x y e1 p1 phi_tmp v volume volume2
    phi = 0;

end


