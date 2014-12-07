% Function BLOOD DETECTION
% detects the blood vessels on an en face image of the retina. The enface
% image is created as an axial summation pixels between the vitreous-RNFL
% interface and the RPE boundary. Frangi vessel enhancing filter is then 
% used on the created en face image, afterwhich the vessels are detected 
% by thresholding the enhanced vessel map. 
function blood = blood_detection(V2,phi)


    % creation of an enface image
    I3 = V2;
    I3(phi(:,:,:,1)>0)=NaN;
    I3(phi(:,:,:,2)<0)=NaN;
    I3 = nanmean(I3,1);
    I3 = squeeze(I3); 
    I3(isnan(I3))= 0;
    I3(I3>0.01) = 0;
    % enface image
    I3 = I3'; 

    % computes eigenvalues and eigenvectors for Frangi 
    % the eigenvalues are order from the largest to the smallest
    
    
    [L1, L2, H, EV_1, EV_2] = computeCurvatureParameters(I3,[1 1]*1.75);
    
    % defining measurment blob like strcutures
    R = L2./L1;
    R(isnan(R)) = 0;
    % vesselness meaurment should be 0 for L1>0
    R(L1>0) = Inf;

    S = sqrt(L1.^2 + L2.^2);


    % set to 0.5
    b = 0.5;
    % related to the values in the image
    c = 6.5*10^-4;
    % vesselness measurment
    Ivess = exp(-(R.^2/(2*b^2))) .* (1-exp(-(S.^2/(2*c^2))));
    % thresholding the image
    I7 = Ivess>0.1; 
    % removing structures that have less than 20 pixels
    I7 = bwareaopen(I7,20);


    % mapping 2d blood vessels to 3d volume
    I7 = I7';
    for i=1:size(I7,2)
        pom = I7(:,i); 
        blood(:,:,i) = repmat(pom',size(V2,1),1);
        clear pom
    end

    blood = imdilate(blood, strel('line',10,0));

end
