% Task 2
% seamless cloning for gray image
function seamlessCloning_gray()

    % read source and target image
    sourceImg = rgb2gray(imread('word.jpg'));
    targetImg = rgb2gray(imread('wall.jpg'));

    % select mask region from source image
    mask_source = roipoly(sourceImg);
    
    close all;
    
    % convert to double format
    sourceImg = double(sourceImg);
    targetImg = double(targetImg);
    mask_source = double(mask_source);
    
    % extract roi (region of interesting) from source image
    roi_source = sourceImg .* mask_source;
    [roi_row_source, roi_col_source] = find(roi_source);
    
    % get the size of roi
    roiHeight = max(roi_row_source) - min(roi_row_source) + 1;
    roiWidth = max(roi_col_source) - min(roi_col_source) + 1;

    % crop roi and mask from source image
    crop_roi_source = roi_source(min(roi_row_source):max(roi_row_source), min(roi_col_source):max(roi_col_source));
    crop_mask_source = mask_source(min(roi_row_source):max(roi_row_source), min(roi_col_source):max(roi_col_source));
    
    % get non-zero pixel index of cropped rectangle
    [roi_row_crop, roi_col_crop] = find(crop_mask_source);
    
    % extract mask boundary from cropped region
    bwBoun = bwboundaries(crop_mask_source);
    maskBounIndex = bwBoun{1};
    crop_mask_boun = zeros(size(crop_mask_source));
    for count = 1: size(maskBounIndex)
        crop_mask_boun(maskBounIndex(count,1),maskBounIndex(count,2))=1;
    end
    
    % extract inner region of mask
    crop_mask_inner = crop_mask_source - crop_mask_boun;
    [inner_row, inner_col] = find(crop_mask_inner);
    
    % select interpolation position in target image
    % assume selected position is left bottom corner of roi
    figure, imshow(uint8(targetImg)), title('Please select interpolation position');
    [posC_target, posR_target] = ginput(1);
    posR_target = round(posR_target);
    posC_target = round(posC_target);
    
    close all;
    
    % validate if the selected position within the target image, here the
    % seleted position corresponds the left corner of the interpolation
    % region
    % if interpolation region exceeds the target image edges, move the
    % region next to the nearest edges
    if (posR_target + roiHeight) > (size(targetImg,1) - 1)
        posR_target = size(targetImg,1) - roiHeight;
    end
    
    if (posC_target + roiWidth) > (size(targetImg,2) - 1)
        posC_target = size(targetImg,2) - roiWidth;
    end
    
    % crop roi from target image
    crop_roi_target = targetImg(posR_target+min(roi_row_crop):posR_target+max(roi_row_crop), posC_target+min(roi_col_crop):posC_target+max(roi_col_crop));
    crop_roi_target = crop_roi_target .* crop_mask_source;
    roi_boun_target = crop_roi_target .* crop_mask_boun;
    
    % interpolate source roi into corresponded position of target image by
    % using two methods
    importing_x = importingGradients(crop_roi_source, crop_mask_inner, roi_boun_target);
    mixing_x = mixingGradients(crop_roi_source, crop_mask_source, crop_mask_inner, crop_roi_target, roi_boun_target, roi_row_crop, roi_col_crop, roiHeight, roiWidth);
    
    % reuslt of importing gradients
    importing_output = targetImg;
    for n = 1: size(importing_x)
        importing_output(posR_target+inner_row(n),posC_target+inner_col(n))=importing_x(n);
    end
    imshow(uint8(importing_output)),title('importing gradients');
           
    % result of mixing gradients
    mixing_result = targetImg;
    for n = 1 : size(mixing_x,1)
        mixing_result (posR_target+inner_row(n),posC_target+inner_col(n))=mixing_x(n);
    end
    figure, imshow(uint8(mixing_result)),title('mixing gradients');
end    