function [MV_choice, mv_indices8x16, mv_indices16x8, mv_indices16x16, mv_indices8x8] = SSD_h264(ref_image, image)

[mv_indices8x16, ssd8x16] = SSD8x16(ref_image, image);
[mv_indices16x8, ssd16x8] = SSD16x8(ref_image, image);
[mv_indices16x16, ssd16x16] = SSD16x16(ref_image, image);
[mv_indices8x8, ssd8x8] = SSD8x8(ref_image, image);

MV_choice = zeros(size(ssd16x16));  
idx_x = 1;
idx_y = 1;
for x = 1:2:size(ssd8x8, 1)
    for y = 1:2:size(ssd8x8, 2)
        ssd8x8Up = sum(sum(ssd8x8(x:x+1, y:y+1)));
        ssd8x16Up = sum(sum(ssd8x16(x:x+1, idx_y)));
        ssd16x8Up = sum(sum(ssd16x8(idx_x, y:y+1)));
        if ssd8x8Up < ssd16x16(idx_x, idx_y)
            MV_choice(idx_x, idx_y) = 1;
        elseif ssd8x16Up < ssd16x16(idx_x, idx_y)
            MV_choice(idx_x, idx_y) = 2;
        elseif ssd16x8Up < ssd16x16(idx_x, idx_y)
            MV_choice(idx_x, idx_y) = 3;
        else
            MV_choice(idx_x, idx_y) = 0;
        end
        idx_y = idx_y+1;
    end
    idx_x = idx_x+1;
    idx_y = 1;
end


end