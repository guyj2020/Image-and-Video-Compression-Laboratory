function [I_frameEnc] = Intra4x4Enc(imgY, QP)

I_frameEnc = blockproc(imgY, [16, 16], @(block_struct) MacroBlock(block_struct.data, QP));

disp("Okay")
end

function macroblock = MacroBlock(block, QP)
macroblock = blockproc(block, [4, 4], @(block_struct) Intra4x4(block_struct.data, block_struct.location, QP, block));
end

function blockEnc = Intra4x4(block4x4, loc, QP, block16x16)
global modesPred

if all(loc == [1, 1])
    blockEnc = IntTrafoQuant4x4(block4x4, QP);

elseif loc(1) == 1
    pred_im = predHor(block4x4, block16x16, loc);
    blockEnc = IntTrafoQuant4x4(pred_im, QP);
    
elseif loc(2) == 1
    pred_im = predVert(block4x4, block16x16, loc);
    blockEnc = IntTrafoQuant4x4(pred_im, QP);
    
else
    blockEnc = IntTrafoQuant4x4(block4x4, QP);
    ssd = inf;
    
    %Horizontal
    pred_imHor = predHor(block4x4, block16x16, loc);
    ssdHor = sum(abs(pred_imHor(:)));
    if ssdHor < ssd
        ssd = ssdHor;
        pred_im = pred_imHor;
        mode = 0;
    end
    
    % Vertical
    pred_imVert = predVert(block4x4, block16x16, loc);
    ssdVert = sum(abs(pred_imVert(:)));
    if ssdVert < ssd
        ssd = ssdVert;
        pred_im = pred_imVert;
        mode = 1;
    end
    
    % DC - Mean
    pred_imDC = predDC(block4x4, block16x16, loc);
    ssdDC = sum(abs(pred_imDC(:)));
    if ssdDC < ssd
        ssd = ssdDC;
        pred_im = pred_imDC;
        mode = 2;
    end
    
    % TODO: ADD All modes
    modesPred(end+1) = mode;
    blockEnc = IntTrafoQuant4x4(pred_im, QP);
end

end

function pred_im = predHor(block4x4, block16x16, loc)
    pred_im = block4x4 - repmat(block16x16(1:4, loc(2)-1), [1, 4]);
end

function pred_im = predVert(block4x4, block16x16, loc)
    pred_im = block4x4 - repmat(block16x16(loc(1)-1, 1:4), [4, 1]);
end

function pred_im = predDC(block4x4, block16x16, loc)
    pred_im = block4x4 - round(mean([block16x16(loc(1)-1, 1:4), block16x16(1:4, loc(2)-1)']));
end

