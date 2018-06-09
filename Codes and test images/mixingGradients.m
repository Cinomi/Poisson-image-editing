% mixing gradients
% crop_roi_source: cropped roi from source image
% crop_mask_source: cropped mask of roi
% crop_mask_inner: cropped inner region mask 
% crop_roi_target: cropped roi from target image
% roi_boun_target: cropped boundary of roi from target image
% roi_row_crop: row index of cropped roi
% roi_col_crop: column index of cropped roi
% roiHeight: height of cropped roi 
% roiWifth: width of cropped roi
function [x]=mixingGradients(crop_roi_source, crop_mask_source, crop_mask_inner, crop_roi_target, roi_boun_target, roi_row_crop, roi_col_crop, roiHeight, roiWidth)

    kernal = [0, 1, 0;
              1, 0, 1;
              0, 1, 0];
    
    % get index of non-zero valus of roi
    roiPosIndex = find(crop_mask_source);
          
    % compute A
    innerIndex = find(crop_mask_inner);
    innerOrder = zeros(size(crop_mask_inner));
    for count = 1: size(innerIndex,1)
        innerOrder(innerIndex(count))=count;
    end
    A = delsq(innerOrder);
    
    % compute v_pq
    b = zeros(size(crop_roi_source));
    
    for i = 1:size(roiPosIndex)
        iter_source = crop_roi_source(roiPosIndex(i));
        iter_target = crop_roi_target(roiPosIndex(i));
        
        % check if current pixel is on the top boundary
        if roi_row_crop(i)==1
            top_source = 0;
            top_target = 0;
        else
            top_source = iter_source - crop_roi_source(roiPosIndex(i)-1);
            top_target = iter_target - crop_roi_target(roiPosIndex(i)-1);
        end
        
        % check if current pixel is on the bottom boundary
        if roi_row_crop(i) == roiHeight
            bottom_source = 0;
            bottom_target = 0;
        else
            bottom_source = iter_source - crop_roi_source(roiPosIndex(i)+1);
            bottom_target = iter_target - crop_roi_target(roiPosIndex(i)+1);
        end
        
        % check if current pixel is on the left boundary
        if roi_col_crop(i) == 1
            left_source = 0;
            left_target = 0;
        else
            left_source = iter_source - crop_roi_source(roiPosIndex(i)-roiHeight);
            left_target = iter_target - crop_roi_target(roiPosIndex(i)-roiHeight);
        end
        
        % check if current pixel is on the right boundary
        if roi_col_crop(i) == roiWidth
            right_source = 0;
            right_target = 0;
        else
            right_source = iter_source - crop_roi_source(roiPosIndex(i)+roiHeight);
            right_target = iter_target - crop_roi_target(roiPosIndex(i)+roiHeight);
        end
        
        if abs(top_source) > abs(top_target)
            b(roiPosIndex(i)) = b(roiPosIndex(i)) + top_source;
        else
            b(roiPosIndex(i)) = b(roiPosIndex(i)) + top_target;
        end
        
        if abs(bottom_source) > abs(bottom_target)
            b(roiPosIndex(i)) = b(roiPosIndex(i)) + bottom_source;
        else
            b(roiPosIndex(i)) = b(roiPosIndex(i)) + bottom_target;
        end
        
        if abs(left_source) > abs(left_target)
            b(roiPosIndex(i)) = b(roiPosIndex(i)) + left_source;
        else
            b(roiPosIndex(i)) = b(roiPosIndex(i)) + left_target;
        end
        
        if abs(right_source) > abs(right_target)
            b(roiPosIndex(i)) = b(roiPosIndex(i)) + right_source;
        else
            b(roiPosIndex(i)) = b(roiPosIndex(i)) + right_target;
        end
    end
    
    b = b .* crop_mask_inner;
    
    % compute target boundary guidance
    mixing_boun_guidance_target = conv2(roi_boun_target, kernal, 'same') .* crop_mask_inner;
    
    % compute b
    b = b + mixing_boun_guidance_target + roi_boun_target;
    b = b(innerIndex);
    
    % compute x
    x = A\b;

end
