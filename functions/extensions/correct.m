% CORRECT
% based on the corr_offset retreived from the mismatch_correction
% allignes all the frames to the central frame
%
function shifted = correct(V2,corr_offset)

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