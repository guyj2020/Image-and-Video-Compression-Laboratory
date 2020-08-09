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
                    loc = [i, j];
                    block8x8 = block16x16(i:i+7, j:j+7);
                    
                    if all(loc == [1, 1])
                        block16x16Enc(i:i+7, j:j+7) = block8x8;

                    elseif loc(1) == 1
                        pred_im = predH(block8x8, block16x16, loc);
                        block16x16Enc(i:i+7, j:j+7) = pred_im;
   
                    elseif loc(2) == 1
                        pred_im = predV(block8x8, block16x16, loc);
                        block16x16Enc(i:i+7, j:j+7) = pred_im;
                    else
                        [block16x16Enc(i:i+7, j:j+7), modesPred] = Intra8x8(block8x8, block16x16, ...
                                                                            modesPred, loc);
                    end
                end
            end
            I_frameCbCr(x:x+15, y:y+15) = block16x16Enc;
        end
    end
    
    I_frameCbCr = blockproc(I_frameCbCr, [4, 4], @(block_struct) IntTrafoQuant4x4(block_struct.data, QP));

end


function [pred_im, modesPred] = Intra8x8(block8x8, block16x16, modesPred, loc)
    pred_im = zeros(size(block8x8));
    ssd = inf;
    % DC
    pre_imDC = predDC(block8x8, block16x16, loc);
    ssdDC = sum(abs(pre_imDC(:)));
    if ssdDC < ssd
        ssd = ssdDC;
        pred_im = pre_imDC;
        mode = 0;
    end

    % Hor
    pre_imH = predH(block8x8, block16x16, loc);
    ssdH = sum(abs(pre_imH(:)));
    if ssdH < ssd
        ssd = ssdH;
        pred_im = pre_imH;
        mode = 1;
    end
    
    % Vert
    pre_imV = predV(block8x8, block16x16, loc);
    ssdV = sum(abs(pre_imV(:)));
    if ssdV < ssd
        ssd = ssdV;
        pred_im = pre_imV;
        mode = 2;
    end
    
    % Plane
    pre_imPlane =  predPlane(block8x8, block16x16, loc);
    ssdPlane = sum(abs(pre_imPlane(:)));
    if ssdPlane < ssd
        ssd = ssdPlane;
        pred_im = pre_imPlane;
        mode = 3;
    end
    
    modesPred(end+1) = mode;
end

function pre_imPlane = predPlane(block8x8, block16x16, loc)
    x = block16x16(loc(1)-1, 1:8);
    y = block16x16(1:8, loc(2)-1);
    pre_imPlaneMat = triu(repmat(x, [8, 1]), 1) + ...
                  tril(repmat(y, [1, 8]));
    pre_imPlane = block8x8 - pre_imPlaneMat;
end

function pred_im = predH(block8x8, block16x16, loc)
    pred_im = block8x8 - repmat(block16x16(1:8, loc(2)-1), [1, 8]);
end

function pred_im = predV(block8x8, block16x16, loc)
    pred_im = block8x8 - repmat(block16x16(loc(1)-1, 1:8), [8, 1]);
end


function pred_im = predDC(block8x8, block16x16, loc)
    pred_im = block8x8 - mean([block16x16(loc(1)-1, 1:8), block16x16(1:8, loc(2)-1)']);
end

