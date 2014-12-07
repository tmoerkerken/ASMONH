% MISMATCH_CORRECTION
% computes the horizontal and vertical offset between two adjacent scans
% using normalized cross - correlation.
% The offset is then used to re-allign all scans to the central scan.
% corr_offset contains information about the offset, while shifted is the re-alligned volume.

function [shifted,corr_offset] = mismatch_correction(V2)

% compute horizontal and vertical offset for the scans before the central frame
    for i=floor(size(V2,3)/2)-1:-1:1

        cc = normxcorr2(V2(:,:,i),V2(:,:,i+1));
        [max_cc, tmpax] = max(abs(cc(:)));
        [ypeak, xpeak] = ind2sub(size(cc),tmpax(1));
        corr_offset(:,i) = -[ (ypeak-size(V2(:,:,i),1)) (xpeak-size(V2(:,:,i),2)) ];
    end

% compute horizontal and vertical offset for the scans after the central frame
    for i=floor(size(V2,3)/2):size(V2,3)-1

        cc = normxcorr2(V2(:,:,i),V2(:,:,i+1));
        [max_cc, tmpax] = max(abs(cc(:)));
        [ypeak, xpeak] = ind2sub(size(cc),tmpax(1));
        corr_offset(:,i) = [ (ypeak-size(V2(:,:,i),1)) (xpeak-size(V2(:,:,i),2)) ];
    end

    shifted = V2;

% re-allign all the scan before the central frame
    for i =1:floor(size(V2,3)/2)-1

        shift_rows = -sum(corr_offset(1,i:floor(size(V2,3)/2)-1));
        shift_cols = -sum(corr_offset(2,i:floor(size(V2,3)/2)-1));
        A = zeros(size(V2(:,:,i)));
        tmp = V2(:,:,i);
        if shift_rows >= 0 && shift_cols >= 0
            A(1+shift_rows:end,1+shift_cols:end) = tmp(1:end-shift_rows,1:end-shift_cols);
        elseif shift_rows >= 0 && shift_cols < 0
            A(1+shift_rows:end,1:end+shift_cols) = tmp(1:end-shift_rows,1-shift_cols:end);
        elseif shift_rows < 0 && shift_cols >= 0
            A(1:end+shift_rows,1+shift_cols:end) = tmp(1-shift_rows:end,1:end-shift_cols);
        else
            A(1:end+shift_rows,1:end+shift_cols) = tmp(1-shift_rows:end,1-shift_cols:end);
        end
        shifted(:,:,i) = A;
    end




% re-allign all the scan after the central frame
    for i =floor(size(V2,3)/2)+1:size(V2,3)

        shift_rows = -sum(corr_offset(1,floor(size(V2,3)/2):i-1));
        shift_cols = -sum(corr_offset(2,floor(size(V2,3)/2):i-1));
        A = zeros(size(V2(:,:,i)));
        tmp = V2(:,:,i);
        if shift_rows >= 0 && shift_cols >= 0
            A(1+shift_rows:end,1+shift_cols:end) = tmp(1:end-shift_rows,1:end-shift_cols);
        elseif shift_rows >= 0 && shift_cols < 0
            A(1+shift_rows:end,1:end+shift_cols) = tmp(1:end-shift_rows,1-shift_cols:end);
        elseif shift_rows < 0 && shift_cols >= 0
            A(1:end+shift_rows,1+shift_cols:end) = tmp(1-shift_rows:end,1:end-shift_cols);
        else
            A(1:end+shift_rows,1:end+shift_cols) = tmp(1-shift_rows:end,1-shift_cols:end);
        end
        shifted(:,:,i) = A;
    end

end
