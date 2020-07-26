function [I_frameCbCr, modesPred] = Intra8x8CbCrEnc(imgCbCr, QP)
% Because blockproc is to random in it's approach of doing things-- for
% loops instead
    modesPred = [];
    I_frameCbCr = zeros(size(imgCbCr));
    for x = 1:16:size(imgCbCr, 1)
        for y = 1:16:size(imgCbCr, 2)
            block16x16 = imgCbCr(x:x+15, y:y+15);
            block16x16Enc = zeros(size(block16x16));
            for i = 1:8:16
                for j = 1:8:16
                    block8x8 = block16x16(i:i+7, j:j+7);
                    [block16x16Enc(i:i+7, j:j+7), modesPred] = Intra8x8(block8x8, ...
                                                                        modesPred);
                end
            end
            I_frameCbCr(x:x+15, y:y+15) = block16x16Enc;
        end
    end
    
    I_frameCbCr = blockproc(I_frameCbCr, [4, 4], @(block_struct) IntTrafoQuant4x4(block_struct.data, QP));

end


function [pred_im, modesPred] = Intra8x8(block8x8, modesPred)
    pred_im = zeros(size(block8x8));
    ssd = inf;
    % DC
    pre_imDC = predDC(block8x8);
    ssdDC = sum(abs(pre_imDC(:)));
    if ssdDC < ssd
        ssd = ssdDC;
        pred_im = pre_imDC;
        mode = 0;
    end

    % Hor
    pre_imH = predH(block8x8);
    ssdH = sum(abs(pre_imH(:)));
    if ssdH < ssd
        ssd = ssdH;
        pred_im = pre_imH;
        mode = 1;
    end
    
    % Vert
    pre_imV = predV(block8x8);
    ssdV = sum(abs(pre_imV(:)));
    if ssdV < ssd
        ssd = ssdV;
        pred_im = pre_imV;
        mode = 2;
    end
    
    % Plane
    pre_imPlane = predPlane(block8x8);
    ssdPlane = sum(abs(pre_imPlane(:)));
    if ssdPlane < ssd
        ssd = ssdPlane;
        pred_im = pre_imPlane;
        mode = 3;
    end
    
    pred_im = block8x8 - pred_im;
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
