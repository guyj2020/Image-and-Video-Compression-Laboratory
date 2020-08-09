function [mv_indices] = cut_motion_vect_mat(MV_choice, mv_indices16x16, mv_indices8x8, mv_indices8x16, mv_indices16x8)

    mv_indices = zeros(2*size(MV_choice));
    
    
    % For Luma Part % 0 for 16x16; 1 for 8x8; 3 for 16x8 and 2 for 8x16
    idxX_8x8 = 1:2:2*size(MV_choice, 1);
    idxY_8x8 = 1:2:2*size(MV_choice, 2);
    
    for x = 1:size(MV_choice, 1)
        for y =1:size(MV_choice, 2)
            if MV_choice(x, y) == 3
                mv_indices(x, idxY_8x8(y):idxY_8x8(y)+1) = mv_indices16x8(x, idxY_8x8(y):idxY_8x8(y)+1);

            elseif MV_choice(x, y) == 2
                mv_indices(idxX_8x8(x):idxX_8x8(x)+1, y) = mv_indices8x16(idxX_8x8(x):idxX_8x8(x)+1, y);

            elseif MV_choice(x, y) == 1
                mv_indices(idxX_8x8(x):idxX_8x8(x)+1, idxY_8x8(y):idxY_8x8(y)+1) = ...
                    mv_indices8x8(idxX_8x8(x):idxX_8x8(x)+1, idxY_8x8(y):idxY_8x8(y)+1);

            else
                mv_indices(x, y) = mv_indices16x16(x, y);

            end
        end
    end
end