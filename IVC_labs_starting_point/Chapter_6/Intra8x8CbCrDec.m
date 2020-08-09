function [I_frameCbCrDec, modesPred] = Intra8x8CbCrDec(imgCbCr, QP, modesPred)

I_frameDecInt = blockproc(imgCbCr, [4, 4], @(block_struct) InvIntTrafoQuant4x4(block_struct.data, QP));
I_frameCbCrDec = zeros(size(imgCbCr));
idx = 1;
for x = 1:16:size(I_frameDecInt, 1)
    for y = 1:16:size(I_frameDecInt, 2)
        block16x16 = I_frameDecInt(x:x+15, y:y+15);
        block16x16Dec = zeros(size(block16x16));
        for i = 1:8:16
            for j = 1:8:16
                loc = [i, j];
                block8x8 = block16x16(i:i+7, j:j+7);
                if all(loc == [1, 1])
                    block16x16Dec(i:i+7, j:j+7) = block8x8;
                elseif loc(1) == 1
                    pred_im = predH(block8x8, block16x16, loc);
                    block16x16Dec(i:i+7, j:j+7) = pred_im;  
                elseif loc(2) == 1
                    pred_im = predV(block8x8, block16x16, loc);
                    block16x16Dec(i:i+7, j:j+7) = pred_im;
                else
%                     [block16x16Dec(i:i+7, j:j+7), idx] = MacroBlock(block8x8, ...
%                                                                    modesPred, idx);
                    block16x16Dec(i:i+7, j:j+7) = Intra8x8(block8x8, block16x16, ...
                                                           loc, modesPred(idx));
                    idx = idx+1;
                end

            end
        end
        I_frameCbCrDec(x:x+15, y:y+15) = block16x16Dec;


%             block16x16Enc(i:i+7, j:j+7) = block8x8;
                            
%         [I_frameCbCrDec(i:i+15, j:j+15), idx] = MacroBlock(I_frameDecInt(i:i+15, j:j+15), ...
%                                                        modesPred, idx);
    end
end

end

% function [macroblock, idx] = MacroBlock(block16x16, modesPred, idx)
%     macroblock = zeros(size(block16x16));
% 
%     for i = 1:8:16
%         for j = 1:8:16
%             macroblock(i:i+7, j:j+7) = Intra8x8(block16x16(i:i+7, j:j+7), ...
%                                                 modesPred(idx));
%             idx = idx+1;
%         end
%     end
%     
% end

function blockEnc = Intra8x8(block8x8, block16x16, loc, mode)

    if mode == 0
        blockEnc = predDC(block8x8, block16x16, loc);
    elseif mode == 1
        blockEnc = predH(block8x8, block16x16, loc);
    elseif mode == 2
        blockEnc = predV(block8x8, block16x16, loc);
    elseif mode == 3
        blockEnc = predPlane(block8x8, block16x16, loc);
    end
end

function pre_imPlane = predPlane(block8x8, block16x16, loc)
    x = block16x16(loc(1)-1, 1:8);
    y = block16x16(1:8, loc(2)-1);
    pre_imPlaneMat = triu(repmat(x, [8, 1]), 1) + ...
                  tril(repmat(y, [1, 8]));
    pre_imPlane = block8x8 + pre_imPlaneMat;
end

function pred_im = predH(block8x8, block16x16, loc)
    pred_im = block8x8 + repmat(block16x16(1:8, loc(2)-1), [1, 8]);
end

function pred_im = predV(block8x8, block16x16, loc)
    pred_im = block8x8 + repmat(block16x16(loc(1)-1, 1:8), [8, 1]);
end


function pred_im = predDC(block8x8, block16x16, loc)
    pred_im = block8x8 + mean([block16x16(loc(1)-1, 1:8), block16x16(1:8, loc(2)-1)']);
end



