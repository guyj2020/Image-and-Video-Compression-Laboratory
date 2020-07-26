function [I_frameCbCrDec, modesPred] = Intra8x8CbCrDec(imgCbCr, QP, modesPred)

I_frameDecInt = blockproc(imgCbCr, [4, 4], @(block_struct) InvIntTrafoQuant4x4(block_struct.data, QP));
I_frameCbCrDec = zeros(size(imgCbCr));
idx = 1;
for i = 1:16:size(I_frameDecInt, 1)
    for j = 1:16:size(I_frameDecInt, 2)
        [I_frameCbCrDec(i:i+15, j:j+15), idx] = MacroBlock(I_frameDecInt(i:i+15, j:j+15), ...
                                                       modesPred, idx);
    end
end

end

function [macroblock, idx] = MacroBlock(block16x16, modesPred, idx)
    macroblock = zeros(size(block16x16));

    for i = 1:4:16
        for j = 1:4:16
            macroblock(i:i+7, j:j+7) = Intra4x4(block16x16(i:i+7, j:j+7), ...
                                                macroblock, modesPred(idx));
            idx = idx+1;
        end
    end
    
end

function blockEnc = Intra8x8(block4x4, block16x16, mode)

    if mode == 0
        pred_im = predHor(block4x4, block16x16, loc);
    elseif mode == 1
        pred_im = predVert(block4x4, block16x16, loc);
    elseif mode == 2
        pred_im = predDC(block4x4, block16x16, loc);
    elseif mode == 3
        pred_im = predPlane(block4x4, block16x16, loc);
    end
    blockEnc = block4x4 + pred_im;
end

function pre_imPlane = predPlane(block8x8)
    pre_imPlane = triu(repmat(block8x8(1, :), [8, 1]), 1) + ...
                  tril(repmat(block8x8(:, 1), [1, 8]));
end

function pre_imV = predV(block8x8)
    pre_imV = zeros(size(block8x8));
    pre_imV(1, :) = block8x8(1, :);
    pre_imV(2:end, :) = repmat(block8x8(1, :), [7, 1]);
end

function pre_imH = predH(block8x8)
    pre_imH = zeros(size(block8x8));
    pre_imH(:, 1) = block8x8(:, 1);
    pre_imH(:, 2:end) = repmat(block8x8(:, 1), [1, 7]);
end

function pre_imDC = predDC(block8x8)
    pre_imDC = zeros(size(block8x8));
    pre_imDC(1, :) = block8x8(1, :);
    pre_imDC(:, 1) = block8x8(:, 1);
    pre_imDC(2:end, 2:end) = repmat(mean(block8x8(:, 1)' + block8x8(1, :)),...
                                    [7, 7]);
end

