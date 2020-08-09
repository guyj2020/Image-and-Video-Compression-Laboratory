function rec_image = SSD_rec16x16(ref_image, motion_vectors)
%  Input         : ref_image(Reference Image, YCbCr image)
%                  motion_vectors
%
%  Output        : rec_image (Reconstructed current image, YCbCr image)

    rec_image = zeros(size(ref_image));
    ref_image = padarray(ref_image, [8, 8], 'both', 'replicate');
    
    for x = 1:size(motion_vectors, 1)
        for y = 1:size(motion_vectors, 2)
            [mvY, mvX] = ind2sub(16+1, motion_vectors(x, y));

            ref_XStart = (x-1)*16+mvX;
            ref_XEnd = x*16+mvX-1;
            ref_YStart = (y-1)*16+mvY;
            ref_YEnd = y*16+mvY-1;


            rec_image(ref_XStart-mvX+1:ref_XEnd-mvX+1, ref_YStart-mvY+1:ref_YEnd-mvY+1, :) = ...
                ref_image(ref_XStart:ref_XEnd, ref_YStart:ref_YEnd, :);
        end 
    end
 
end
 


