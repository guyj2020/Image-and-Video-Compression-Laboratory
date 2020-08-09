function [motion_vectors_indices, ssd] = SSD16x8(ref_image, image)
%  Input         : ref_image(Reference Image, size: height x width)
%                  image (Current Image, size: height x width)
%
%  Output        : motion_vectors_indices (Motion Vector Indices, size: (height/8) x (width/8) x 1 )

ref_image = padarray(ref_image, [8, 4], 'both', 'replicate');
motion_vectors_indices = blockproc(image, [16, 8], @(block_struct) BlockSSDMV(block_struct.data, block_struct.location, ref_image));
ssd = blockproc(image, [16, 8], @(block_struct) BlockSSD(block_struct.data, block_struct.location, ref_image));

end

function motion_vector_indices = BlockSSDMV(block, loc, ref_image)

loc = loc + size(block)/2;
sse_min = inf;
best_loc = loc;
for x = -size(block, 1)/2:size(block, 1)/2
    for y = -size(block, 2)/2:size(block, 2)/2
        sse = sum(sum( (block-ref_image(loc(1)+x:loc(1)+x+size(block, 1)-1, loc(2)+y:loc(2)+y+size(block, 2)-1)).^2 ));
        if sse_min > sse
            best_loc(1) = x+9;
            best_loc(2) = y+5;
            sse_min = sse;
        end
    end
end
motion_vector_indices = sub2ind(fliplr(size(block)+1), best_loc(2), best_loc(1));
end

function sse_min = BlockSSD(block, loc, ref_image)

loc = loc + size(block)/2;
sse_min = inf;
for x = -size(block, 1)/2:size(block, 1)/2
    for y = -size(block, 2)/2:size(block, 2)/2
        sse = sum(sum( (block-ref_image(loc(1)+x:loc(1)+x+size(block, 1)-1, loc(2)+y:loc(2)+y+size(block, 2)-1)).^2 ));
        if sse_min > sse
            sse_min = sse;
        end
    end
end
end

