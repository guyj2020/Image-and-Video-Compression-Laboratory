function qImage = ApplyVectorQuantizer(image, clusters, bsize)
%  Function Name : ApplyVectorQuantizer.m
%  Input         : image    (Original Image)
%                  clusters (Quantization Representatives)
%                  bsize    (Block Size)
%  Output        : qImage   (Quantized Image)
    % Create Blocks of size bsizexbsize -> vec those blocks
    image1D = [image(:, :, 1), image(:, :, 2), image(:, :, 3)]; 
    N1 = bsize*ones(1,size(image1D, 1)/bsize);
    N2 = bsize*ones(1,size(image1D, 2)/bsize);

    cellImage1D = mat2cell(image1D, N1, N2);
    vecFCN = @(blk) blk(:);
    matImage1DVec = cell2mat(cellfun(vecFCN, cellImage1D, 'UniformOutput', false));
    vecImg = reshape(matImage1DVec(:), [4, numel(image1D)/4])';

    [qImage, ~] = knnsearch(clusters, vecImg, 'Distance', 'euclidean');
    qImage = reshape(qImage, [size(image, 1)/bsize, size(image, 2)/bsize, size(image, 3)]);

end


%%
