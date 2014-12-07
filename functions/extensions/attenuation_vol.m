% ATTENUATION_VOL
% transforms the raw OCT volume to attenuation coefficients
% based on the work of Koen Vermeer
% K. A. Vermeer, J. Mo, J. J. A. Weda, H. G. Lemij, and J. F. de Boer, 
% 'Depth-Resolved Model-Based Reconstruction of Attenuation Coefficients in Optical Coherence Tomography', 
% Biomedical Optics Express, 5 (2014), 322-37

function final = attenuation_vol(V)
    for i = 1:size(V,3)
	
        img = V(:,:,i)';
        img(img==0)=1e-6;
        img(img>10)=1e-6;

        %img = img.^(4);

        n=1;
        D=size(img,1);


        mu_1 = -1./D*log(0.001)*ones(size(img));

        % initial iteration
        suma = cumsum(mu_1,1);
        tmp = zeros(size(mu_1));
        tmp(3:end,:) = (mu_1(2:end-1,:));
        tmp = cumsum(tmp,1);
        suma = 0.5*(suma+tmp);
        suma(1,:) = 2*suma(1,:);

        beta(:,:,1) = img.*exp(suma);


        suma = flipud(cumsum(flipud(beta(:,:,1)),1));
        tmp = zeros(size(beta(:,:,1)));
        b = flipud(beta(:,:,1));
        tmp(3:end,:) =(b(2:end-1,:));
        tmp = flipud(tmp);
        tmp = flipud(cumsum((flipud(tmp)),1));

        suma = 0.5*(suma+tmp);
        suma(end,:) = 2*suma(end,:);
        mu(:,:,1) = beta(:,:,1)./suma;



        for k= 2:30

            suma = cumsum(mu(:,:,k-1),1);
            tmp = zeros(size(mu(:,:,k-1)));
            tmp(3:end,:) = (mu(2:end-1,:,k-1));
            tmp = cumsum(tmp,1);
            suma = 0.5*(suma+tmp);
            suma(1,:) = 2*suma(1,:);

            beta(:,:,k) = img.*exp(suma);

            suma = flipud(cumsum(flipud(beta(:,:,k)),1));
            tmp = zeros(size(beta(:,:,k)));
            b = flipud(beta(:,:,k));
            tmp(3:end,:) =(b(2:end-1,:));
            tmp = flipud(tmp);
            tmp = flipud(cumsum((flipud(tmp)),1));

            suma = 0.5*(suma+tmp);
            suma(end,:) = 2*suma(end,:);
            mu(:,:,k) = beta(:,:,k)./suma;
            mu(:,:,k) = (mu(:,:,k) + mu(:,:,k-1))./2;
        end

        final(:,:,i) = mu(:,:,k);
    end
   % figure,imshow((log(mu(:,:,k))),[-10, max(max(log(mu(:,:,k))))])
end





