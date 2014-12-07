%SEGPLOT plots B-scans with a region growing area
%
%   SYNOPSIS:  
%       SEGPLOT(SUBJECT,MEASUREMENT,INTENSITY, SCAN)
%           SUBJECT     format: integer
%           MEASUREMENT format: integer
%           INTENSITY   format: double
%           SCAN        format: integer
%
%   REQUIREMENTS:
%           DIPIMAGE

function segplot(subject, measurement, intensity, scan)  
    if (exist('intensity')==1)
        int = intensity;
    else
        int = 0.1;
    end
    
    path = ['subjects\Subject ' num2str(subject) '\segment\'];
    filename = [num2str(int,'%10.3f\n') '_Subject ' num2str(subject) '_' num2str(measurement) '_segment_RNFL.mat'];
    load([path filename],'image_after','phi');
    
    if (~exist('scan')==1)
        figure; dipshow(imcomplement(image_after.^.25)+phi(1:size(image_after,1),:,:),'unit');
    else
        figure; imshow(imcomplement(image_after(:,:,scan).^.25)), hold on, contour(phi(1:size(image_after,1),:,scan),'r'), hold off
    end
    
end