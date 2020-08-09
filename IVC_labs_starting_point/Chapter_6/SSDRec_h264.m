function rec_image = SSDRec_h264(ref_image, MV_choice, mv_indices16x16, mv_indices)

rec_image = zeros(size(ref_image));
ref_image16x16 = padarray(ref_image, [8, 8], 'both', 'replicate');

idxX_8x8 = 1:2:2*size(MV_choice, 1);
idxY_8x8 = 1:2:2*size(MV_choice, 2);

for idxX_choice = 1:size(MV_choice, 1)
    for idxY_choice = 1:size(MV_choice, 2)
        if MV_choice(idxX_choice, idxY_choice) == 1
            mv_indice = mv_indices(idxX_8x8(idxX_choice):idxX_8x8(idxX_choice)+1, ...
                                      idxY_8x8(idxY_choice):idxY_8x8(idxY_choice)+1);
                                  
            mv_indice16x16 = mv_indices16x16(idxX_choice, idxY_choice);
            [mvY, mvX] = ind2sub(16+1, mv_indice16x16);
            
            ref_XStart16x16 = (idxX_choice-1)*16+mvX;
            ref_XEnd16x16 = idxX_choice*16+mvX-1;
            ref_YStart16x16 = (idxY_choice-1)*16+mvY;
            ref_YEnd16x16 = idxY_choice*16+mvY-1;
                        
            for x = 1:size(mv_indice, 1)
                for y = 1:size(mv_indice, 2)
                    ref_XStart = ref_XStart16x16 + (x-1)*8;
                    ref_XEnd = ref_XEnd16x16 + (x-2)*8;
                    ref_YStart = ref_YStart16x16 + (y-1)*8;
                    ref_YEnd = ref_YEnd16x16 + (y-2)*8;


                    rec_image(ref_XStart-mvX+1:ref_XEnd-mvX+1, ref_YStart-mvY+1:ref_YEnd-mvY+1, :) = ...
                        ref_image16x16(ref_XStart:ref_XEnd, ref_YStart:ref_YEnd, :);
                end 
            end

        elseif MV_choice(idxX_choice, idxY_choice) == 0
            mv_indice = mv_indices16x16(idxX_choice, idxY_choice);
            [mvY, mvX] = ind2sub(16+1, mv_indice);

            ref_XStart = (idxX_choice-1)*16+mvX;
            ref_XEnd = idxX_choice*16+mvX-1;
            ref_YStart = (idxY_choice-1)*16+mvY;
            ref_YEnd = idxY_choice*16+mvY-1;

            rec_image(ref_XStart-mvX+1:ref_XEnd-mvX+1, ref_YStart-mvY+1:ref_YEnd-mvY+1, :) = ...
                ref_image16x16(ref_XStart:ref_XEnd, ref_YStart:ref_YEnd, :); % Change to only Y later on
            
            
        elseif MV_choice(idxX_choice, idxY_choice) == 2
            mv_indice = mv_indices(idxX_8x8(idxX_choice):idxX_8x8(idxX_choice)+1, ...
                                       idxY_choice);
                                  
            mv_indice16x16 = mv_indices16x16(idxX_choice, idxY_choice);
            [mvY, mvX] = ind2sub(16+1, mv_indice16x16);
            
            ref_XStart16x16 = (idxX_choice-1)*16+mvX;
            ref_XEnd16x16 = idxX_choice*16+mvX-1;
            ref_YStart = (idxY_choice-1)*16+mvY;
            ref_YEnd = idxY_choice*16+mvY-1;

            for x = 1:size(mv_indice, 1)
                for y = 1:size(mv_indice, 2)
                    ref_XStart = ref_XStart16x16 + (x-1)*8;
                    ref_XEnd = ref_XEnd16x16 + (x-2)*8; 

                    rec_image(ref_XStart-mvX+1:ref_XEnd-mvX+1, ref_YStart-mvY+1:ref_YEnd-mvY+1, :) = ...
                        ref_image16x16(ref_XStart:ref_XEnd, ref_YStart:ref_YEnd, :);
                end 
            end
            
        elseif MV_choice(idxX_choice, idxY_choice) == 3
            mv_indice = mv_indices(idxX_choice, ...
                                      idxY_8x8(idxY_choice):idxY_8x8(idxY_choice)+1);
      
            mv_indice16x16 = mv_indices16x16(idxX_choice, idxY_choice);
            [mvY, mvX] = ind2sub(16+1, mv_indice16x16);
            
            ref_XStart = (idxX_choice-1)*16+mvX;
            ref_XEnd = idxX_choice*16+mvX-1;
            ref_YStart16x16 = (idxY_choice-1)*16+mvY;
            ref_YEnd16x16 = idxY_choice*16+mvY-1;

            
            for x = 1:size(mv_indice, 1)
                for y = 1:size(mv_indice, 2)
                    ref_YStart = ref_YStart16x16 + (y-1)*8;
                    ref_YEnd = ref_YEnd16x16 + (y-2)*8; 

                    rec_image(ref_XStart-mvX+1:ref_XEnd-mvX+1, ref_YStart-mvY+1:ref_YEnd-mvY+1, :) = ...
                        ref_image16x16(ref_XStart:ref_XEnd, ref_YStart:ref_YEnd, :);
                end 
            end

        end
    end
end


end