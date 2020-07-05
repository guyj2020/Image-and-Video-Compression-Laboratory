function motion_vectors_indices = SSD(ref_image, image)
%  Input         : ref_image(Reference Image, size: height x width)
%                  image (Current Image, size: height x width)
%
%  Output        : motion_vectors_indices (Motion Vector Indices, size: (height/8) x (width/8) x 1 )

ref_image = padarray(ref_image, [4, 4], 'both', 'replicate');
motion_vectors_indices = blockproc(image, [8, 8], @(block_struct) BlockSSD(block_struct.data, block_struct.location, ref_image));

end

function motion_vector_indices = BlockSSD(block, loc, ref_image)

loc = loc + size(block)/2;
sse_min = inf;
best_loc = loc;
for x = -size(block, 1)/2:size(block, 1)/2
    for y = -size(block, 2)/2:size(block, 2)/2
        sse = sum(sum( (block-ref_image(loc(1)+x:loc(1)+x+size(block, 1)-1, loc(2)+y:loc(2)+y+size(block, 2)-1)).^2 ));
        if sse_min > sse
            best_loc(1) = x+5;
            best_loc(2) = y+5;
            sse_min = sse;
        end
    end
end
motion_vector_indices = sub2ind(size(block)+1, best_loc(2), best_loc(1));
end

function rec_image = SSD_rec(ref_image, motion_vectors)
%  Input         : ref_image(Reference Image, YCbCr image)
%                  motion_vectors
%
%  Output        : rec_image (Reconstructed current image, YCbCr image)


    rec_image = zeros(size(ref_image));
    ref_image = padarray(ref_image, [4, 4], 'both', 'replicate');
    
    for x = 1:size(motion_vectors, 1)
        for y = 1:size(motion_vectors, 2)
            [mvY, mvX] = ind2sub(8+1, motion_vectors(x, y));
            
            ref_XStart = (x-1)*8+mvX;
            ref_XEnd = x*8+mvX-1;
            ref_YStart = (y-1)*8+mvY;
            ref_YEnd = y*8+mvY-1;
            
                        
            rec_image(ref_XStart-mvX+1:ref_XEnd-mvX+1, ref_YStart-mvY+1:ref_YEnd-mvY+1, :) = ...
                ref_image(ref_XStart:ref_XEnd, ref_YStart:ref_YEnd, :);
        end 
    end
 
end

