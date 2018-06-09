% Task 5
% local color changes: given an original color image and a selection omega,
% two differently colored versions of this image can be mixed seamlessly:
% one provides destination function f* outside omega, another provides the
% source function g to be modified within omega.
function localColorChanges()

    % read source and target image
    sourceImg = imread('pink-flower.jpg');
    
    % select mask from source image
    mask_source = roipoly(sourceImg);
    
    close all;
    
    % convert to double format
    sourceImg = double(sourceImg);
    targetImg = sourceImg;
    mask_source = double(mask_source);
    
    % get RGB channels of source image
    source_R = sourceImg(:,:,1).* 20.0;
    source_G = sourceImg(:,:,2).* 0.0;
    source_B = sourceImg(:,:,3).* 1.5;
    
    % get RGB channels of target image
    target_R = targetImg(:,:,1);
    target_G = targetImg(:,:,2);
    target_B = targetImg(:,:,3);
    
    % extract three channels of roi from source image
    roi_source_R = source_R .* mask_source;
    roi_source_G = source_G .* mask_source;
    roi_source_B = source_B .* mask_source;
    
    % get non-zero pixel index
    [roi_row, roi_col] = find(mask_source);
    [roiHeight, roiWidth] = size(mask_source);
    
    % extract mask boundary
    bwBoun = bwboundaries(mask_source);
    maskBounIndex = bwBoun{1};
    mask_boun = zeros(size(mask_source));
    for count = 1 : size(maskBounIndex)
        mask_boun(maskBounIndex(count,1),maskBounIndex(count,2))=1;
    end
    
    % extract inner region mask and roi
    mask_inner = mask_source - mask_boun;
    [inner_row, inner_col] = find(mask_inner);
    
    % extract roi from target image
    roi_target_R = target_R .* mask_source;
    roi_target_G = target_G .* mask_source;
    roi_target_B = target_B .* mask_source;
    roi_boun_target_R = roi_target_R .* mask_boun;
    roi_boun_target_G = roi_target_G .* mask_boun;
    roi_boun_target_B = roi_target_B .* mask_boun;
    
    % importing gradients
    importing_x_R = importingGradients(roi_source_R, mask_inner, roi_boun_target_R);
    importing_x_G = importingGradients(roi_source_G, mask_inner, roi_boun_target_G);
    importing_x_B = importingGradients(roi_source_B, mask_inner, roi_boun_target_B);
    
    importing_output_R = target_R;
    importing_output_G = target_G;
    importing_output_B = target_B;
    for n = 1: size(importing_x_R)
        importing_output_R(inner_row(n),inner_col(n))=importing_x_R(n);
        importing_output_G(inner_row(n),inner_col(n))=importing_x_G(n);
        importing_output_B(inner_row(n),inner_col(n))=importing_x_B(n);
    end
    importing_result = cat(3, importing_output_R, importing_output_G, importing_output_B);
    subplot(1,3,1), imshow(uint8(targetImg)), title('original image');
    subplot(1,3,2), imshow(uint8(importing_result)), title('importing gradients');
    
    % mixing gradients
    mixing_x_R = mixingGradients(roi_source_R, mask_source, mask_inner, roi_target_R, roi_boun_target_R, roi_row, roi_col, roiHeight, roiWidth);
    mixing_x_G = mixingGradients(roi_source_G, mask_source, mask_inner, roi_target_G, roi_boun_target_G, roi_row, roi_col, roiHeight, roiWidth);
    mixing_x_B = mixingGradients(roi_source_B, mask_source, mask_inner, roi_target_B, roi_boun_target_B, roi_row, roi_col, roiHeight, roiWidth);
    
    mixing_output_R = target_R;
    mixing_output_G = target_G;
    mixing_output_B = target_B;
    for n = 1:size(mixing_x_R)
        mixing_output_R(inner_row(n),inner_col(n))=mixing_x_R(n);
        mixing_output_G(inner_row(n),inner_col(n))=mixing_x_G(n);
        mixing_output_B(inner_row(n),inner_col(n))=mixing_x_B(n);
    end
   mixing_result = cat(3, mixing_output_R, mixing_output_G, mixing_output_B);
   subplot(1,3,3), imshow(uint8(mixing_result)),title('mixing gradients');
end

