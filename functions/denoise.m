%DENOISE manually les the user selectan area to add or delete tissue.
%   SYNOPSIS:  DENOISE(SUBJECT,MEASUREMENT,RANGE,FILLTYPE)
%       SUBJECT     format: integer
%       MEASUREMENT format: integer
%       RANGE       format: integer or range [a b]
%       FILLTYPE    format: double
%                   default: 0

function denoise(subject, measurement, range, filltype)  
    if (exist('filltype')==1)
        fillt = filltype;
    else
        fillt = 0;
    end
    
    path = ['subjects\Subject ' num2str(subject) '\presegment\'];
    filename = ['Subject ' num2str(subject) '_' num2str(measurement) '_presegment'];
    load([path filename],'V2');
    
    figure,
    for i = min(range):max(range)
        tmp = V2(:,:,i);
        imshow(tmp.^.15);
        set(gcf,'units','normalized','outerposition',[0 0 1 1])
        h = imfreehand;
        tmp(h.createMask) = fillt;
        V2(:,:,i) = tmp;
    end
    
    choice = menu('Save edited scan?','Overwrite files','Abort');
    switch choice
        case 1
            save([path filename], 'V2','-append');
        case 2
            
    end
    
end