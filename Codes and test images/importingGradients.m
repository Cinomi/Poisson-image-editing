% Importing gradients
% crop_roi_source: cropped roi from source image
% crop_mask_inner: cropped inner region mask 
% roi_inner_source: cropped inner region of source image
% roi_boun_target: cropped boundary of roi from target image
function [x]=importingGradients(crop_roi_source, crop_mask_inner, roi_boun_target)
    
    laplacian = [0, -1, 0;
                 -1, 4, -1;
                 0, -1, 0];
    kernal = [0, 1, 0;
              1, 0, 1;
              0, 1, 0];
      
    % compute A
    innerIndex = find(crop_mask_inner);
    innerOrder = zeros(size(crop_mask_inner));
    for count = 1: size(innerIndex,1)
        innerOrder(innerIndex(count))=count;
    end
    A = delsq(innerOrder);
    
    % compute v_pq
    roi_guidance_source = conv2(crop_roi_source, laplacian, 'same') .* crop_mask_inner;
    
    % compute f*
    boundary_guidance_target = conv2(roi_boun_target, kernal, 'same');
    
    % compute b
    b = roi_guidance_source + boundary_guidance_target;
    b = b(innerIndex);
    
    % solve x
    x = A\b;       
end