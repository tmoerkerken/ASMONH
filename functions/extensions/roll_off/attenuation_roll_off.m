function [V3,miss] = attenuation_roll_off(V2)  


    for i =1:size(V2,3)
        V(:,:,i) = V2(:,:,i)';
    end

    clear SLO_image SLO
    miss = logical(V>1);
    V(miss ==1) = 10^-6;

    vitreous = rnfl_detection2(V2,V,miss);
    
    V3 = noise_spectralis(vitreous,V2);

    
    for i=1:size(V2,3)
        tmp = attenuation(V3(:,:,i)'); 
        V3(:,:,i) = tmp';
%         tmp = attenuation(V1(:,:,i)); 
%         V4(:,:,i) = tmp';
        miss2(:,:,i) = isnan(V3(:,:,i));
    end
        V3 = single(V3);
        miss = or(miss,logical(miss2));

end