% Task 1
% select a grayscale image
% make out a region R using a polygon
% remove the selected region R and fill in with equation (2)

% as the size of selected region increases, the computational cost and
% running time increases.

% input: input -- input RGB image
% output: output -- interpolated gray image
function  [output] = poissonInterpolation (input)
    
    grayImg = rgb2gray(input);
    
    % make out a region using a polygon
    polyMask = roipoly(grayImg);
    polyMask = double(polyMask);
    doubleImg = double(grayImg);
    
    close all;
    
    % get boundary index of selected region
    bwBoun = bwboundaries(polyMask);
    maskBoun = bwBoun{1};                  % row and col index of boundary is stored in the first cell of bwBoun
    bounImg = zeros(size(polyMask));       % maskBoun is an nx2 array, where n is number of pixels in boundary
    
    % record boundary of mask in whole image
    for n = 1:size(maskBoun)
        bounImg(maskBoun(n,1),maskBoun(n,2))=doubleImg(maskBoun(n,1),maskBoun(n,2));  % record boundary of mask        
    end
    
    % figure,imshow(bounImg);
    
    % record inner region of mask in whole image
    innerImg = doubleImg.* polyMask - bounImg;

    % get index of inner region pixel
    innerIndex = find(innerImg);
    [innerR, innerC] = find(innerImg);
    innerOrder = zeros(size(innerImg));     % store index of all non-zero value
    for count = 1:size(innerIndex)
        innerOrder(innerIndex(count))=count;
    end
    
    % construct a five-point finite difference laplacian (sparse form)
    % A is a standard sparse Laplacian matrix of (N*N), where N is the
    % number of pixel within selected region
    A = delsq(innerOrder);  
    
    % b is a N-element vector
    % b = v_pq + f*
    % here the guidence field v is 0 in task1, so here use the f*(boundary) 
    % to help fill the region
    
    % do convolution onto boundary
    kernal = [0, 1, 0;
              1, 0, 1;
              0, 1, 0];
    b = conv2(bounImg, kernal, 'same');  
    b = b(innerIndex);
      
    % compute filled region
    x = A\b;
    
    % apply filled pixel into the region
    for index = 1 : length(x)
        grayImg(innerR(index),innerC(index))=x(index);
    end
    
    output = uint8(grayImg);
    figure,imshow(output), title('Resulted Image');
end