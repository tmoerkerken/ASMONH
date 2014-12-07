    
function V2 = noise_spectralis(vitreous,V2)

    load('spectralis.mat')
    N1 = (spec_noise)'; 
    clear spec_noise % measured depth dependent noise
    Nv = (squeeze(nanmean((squeeze(nanmean(vitreous,2))),2))); % depth dependent noise from vitreous
    % noise N1 is aproximated with alpha*Nv
    % least square fit with a realibility measurment was performed
    weight = (squeeze(nansum((squeeze(nansum(~isnan(vitreous),2))),2))); % weight for realibility measurment
    
    Nv(isnan(Nv)) = 0;
    fun = @(A) (A*double(Nv) - N1).*weight./max(weight(:));
    alpha = lsqnonlin(fun,0.1);
    
%     figure,plot(alpha*Nv), hold on, plot(N1,'r')
    clear vitreous Nv weight fun
    % roll off estimation
    w = 2.145;
    
    for i=1:size(V2,1)
        for j=1:size(V2,3)
            [a,b] = findpeaks(abs(diff(V2(i,:,j)>1)));
            
            if size(b,2)~=1
                z = (1:size(V2,2))/size(V2,2);
                clear b a
                
            else
                if b > size(V2,2)/2
                    % treba ga spustit dolje
                    z = size(V2,2)-b:size(V2,2)-b+size(V2,2)-1;
                    z = z/size(V2,2);
                else
                    z = 1-b:size(V2,2)-b;
                    z = z/size(V2,2);
                end
                clear a b
            end
            
            z = z*pi/2;
            Rz(:,i,j) = z;
            clear z
        end
    end
    R = roll_off(Rz,w);
   

    clear w z  i j Rz
    V = V2; 
    V1 = V; V1(V1>1) = NaN;
    for i=1:size(V,3)
        V3(:,:,i) = V1(:,:,i)';
    end
    
    clear V1 V2
    
    V2  = (alpha*V3-repmat(N1,[1 size(V,1) size(V,3)]))./R;
%     V3  = (V1)./R;
%     V4 = (V1-exp(a2));
    clear V V1 V3
end