% Task 3
% seamless cloning for RGB image
function seamlessCloning_rgb()

    % read source and target image
    sourceImg = imread('word.jpg');
    targetImg = imread('wall.jpg');
    
    % select mask from source image
    mask_source = roipoly(sourceImg);
    
    close all;
    
    % convert to double format
    sourceImg = double(sourceImg);
    targetImg = double(targetImg);
    mask_source = double(mask_source);
    
    % get RGB channels of source image
    source_R = sourceImg(:,:,1);
    source_G = sourceImg(:,:,2);
    source_B = sourceImg(:,:,3);
    
    % get RGB channels of target image
    target_R = targetImg(:,:,1);
    target_G = targetImg(:,:,2);
    target_B = targetImg(:,:,3);
    
    % extract three channels of roi from source image
    roi_source_R = source_R .* mask_source;
    roi_source_G = source_G .* mask_source;
    roi_source_B = source_B .* mask_source;
    [roi_row_source, roi_col_source] = find(mask_source);
    
    % get size of roi
    roiHeight = max(roi_row_source) - min(roi_row_source) + 1;
    roiWidth = max(roi_col_source) - min(roi_col_source) + 1;
    
    % crop roi and mask from source image
    crop_roi_source_R = roi_source_R(min(roi_row_source):max(roi_row_source), min(roi_col_source):max(roi_col_source));
    crop_roi_source_G = roi_source_G(min(roi_row_source):max(roi_row_source), min(roi_col_source):max(roi_col_source));
    crop_roi_source_B = roi_source_B(min(roi_row_source):max(roi_row_source), min(roi_col_source):max(roi_col_source));
    crop_mask_source = mask_source(min(roi_row_source):max(roi_row_source), min(roi_col_source):max(roi_col_source));
    
    % get non-zero pixel index
    [roi_row_crop, roi_col_crop] = find(crop_mask_source);
    
    % extract mask boundary
    bwBoun = bwboundaries(crop_mask_source);
    maskBounIndex = bwBoun{1};
    crop_mask_boun = zeros(size(crop_mask_source));
    for count = 1 : size(maskBounIndex)
        crop_mask_boun(maskBounIndex(count,1),maskBounIndex(count,2))=1;
    end
    
    % extract inner region mask 
    crop_mask_inner = crop_mask_source - crop_mask_boun;
    [inner_row, inner_col] = find(crop_mask_inner);
    
    % select interpolation position in target image
    % assume selected position is the left top corner of roi
    figure, imshow(uint8(targetImg)), title('Please choose the position to interpolate');
    [posC_target, posR_target] = ginput(1);
    posR_target = round(posR_target);
    posC_target = round(posC_target);
    
    close all;
    
    % validate if the selected position within the target image
    if (posR_target + roiHeight) > (size(targetImg,1) - 1)
        posR_target = size(targetImg,1) - roiHeight;
    end
    
    if (posC_target + roiWidth) > (size(targetImg,2) - 1)
        posC_target = size(targetImg,2) - roiWidth;
    end
    
    % crop roi from target image
    crop_roi_target_R = target_R(posR_target+min(roi_row_crop):posR_target+max(roi_row_crop),posC_target+min(roi_col_crop):posC_target+max(roi_col_crop));
    crop_roi_target_G = target_G(posR_target+min(roi_row_crop):posR_target+max(roi_row_crop),posC_target+min(roi_col_crop):posC_target+max(roi_col_crop));
    crop_roi_target_B = target_B(posR_target+min(roi_row_crop):posR_target+max(roi_row_crop),posC_target+min(roi_col_crop):posC_target+max(roi_col_crop));
    crop_roi_target_R = crop_roi_target_R .* crop_mask_source;
    crop_roi_target_G = crop_roi_target_G .* crop_mask_source;
    crop_roi_target_B = crop_roi_target_B .* crop_mask_source;
    roi_boun_target_R = crop_roi_target_R .* crop_mask_boun;
    roi_boun_target_G = crop_roi_target_G .* crop_mask_boun;
    roi_boun_target_B = crop_roi_target_B .* crop_mask_boun;
    
    % importing gradients
    importing_x_R = importingGradients(crop_roi_source_R, crop_mask_inner, roi_boun_target_R);
    importing_x_G = importingGradients(crop_roi_source_G, crop_mask_inner, roi_boun_target_G);
    importing_x_B = importingGradients(crop_roi_source_B, crop_mask_inner, roi_boun_target_B);
    
    importing_output_R = target_R;
    importing_output_G = target_G;
    importing_output_B = target_B;
    for n = 1: size(importing_x_R)
        importing_output_R(posR_target+inner_row(n),posC_target+inner_col(n))=importing_x_R(n);
        importing_output_G(posR_target+inner_row(n),posC_target+inner_col(n))=importing_x_G(n);
        importing_output_B(posR_target+inner_row(n),posC_target+inner_col(n))=importing_x_B(n);
    end
    importing_result = cat(3, importing_output_R, importing_output_G, importing_output_B);
    imshow(uint8(importing_result)), title('importing gradients');
    
    % mixing gradients
    mixing_x_R = mixingGradients(crop_roi_source_R, crop_mask_source, crop_mask_inner, crop_roi_target_R, roi_boun_target_R, roi_row_crop, roi_col_crop, roiHeight, roiWidth);
    mixing_x_G = mixingGradients(crop_roi_source_G, crop_mask_source, crop_mask_inner, crop_roi_target_G, roi_boun_target_G, roi_row_crop, roi_col_crop, roiHeight, roiWidth);
    mixing_x_B = mixingGradients(crop_roi_source_B, crop_mask_source, crop_mask_inner, crop_roi_target_B, roi_boun_target_B, roi_row_crop, roi_col_crop, roiHeight, roiWidth);
    
    mixing_output_R = target_R;
    mixing_output_G = target_G;
    mixing_output_B = target_B;
    for n = 1:size(mixing_x_R)
        mixing_output_R(posR_target+inner_row(n),posC_target+inner_col(n))=mixing_x_R(n);
        mixing_output_G(posR_target+inner_row(n),posC_target+inner_col(n))=mixing_x_G(n);
        mixing_output_B(posR_target+inner_row(n),posC_target+inner_col(n))=mixing_x_B(n);
    end
   mixing_result = cat(3, mixing_output_R, mixing_output_G, mixing_output_B);
   figure, imshow(uint8(mixing_result)),title('mixing gradients');
end