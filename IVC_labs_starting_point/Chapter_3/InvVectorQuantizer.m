function image = InvVectorQuantizer(qImage, clusters, block_size)
%  Function Name : VectorQuantizer.m
%  Input         : qImage     (Quantized Image)
%                  clusters   (Quantization clusters)
%                  block_size (Block Size)
%  Output        : image      (Dequantized Images)

    image = zeros(size(qImage, 1)*block_size, size(qImage, 2)*block_size, size(qImage, 3));
    imageClusterVec = clusters(qImage(:), :);

    imageClusterVecRep = repelem(imageClusterVec, block_size, 1);
    swap1 = imageClusterVecRep(:, 2);
    swap2 = imageClusterVecRep(:, 3);
    imageClusterVecRep(:, 2) = swap2;
    imageClusterVecRep(:, 3) = swap1;
    
    for bsize = 1:block_size
        lb = (bsize-1)*block_size + 1;
        rb = (bsize)*block_size;
        imageClusterVecRep(bsize:block_size:end, 1:block_size) = imageClusterVecRep(1:block_size:end, lb:rb);
    end
    
    imageClusterVecRep(:, block_size+1:end) = [];

    qI = 1;
    for depth = 1:size(image, 3)
       for y = 1:2:size(image, 2)
           for x = 1:2:size(image, 1)
               image(x:x+1, y:y+1, depth) = imageClusterVecRep(qI:qI+block_size-1, :);
               qI = qI + 2;
           end
       end
    end


end