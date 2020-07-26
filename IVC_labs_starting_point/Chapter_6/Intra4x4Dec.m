function I_frameDec = Intra4x4Dec(I_frameEnc, QP, modesPred)

I_frameDecInt = blockproc(I_frameEnc, [4, 4], @(block_struct) InvIntTrafoQuant4x4(block_struct.data, QP));
% I_frameDec = blockproc(I_frameDecInt, [16, 16], @(block_struct) MacroBlock(block_struct.data));

idx = 1;
for i = 1:16:size(I_frameDecInt, 1)
    for j = 1:16:size(I_frameDecInt, 2)
        [I_frameDec(i:i+15, j:j+15), idx] = MacroBlock(I_frameDecInt(i:i+15, j:j+15), ...
                                                       modesPred, idx);
    end
end

end

function [macroblock, idx] = MacroBlock(block16x16, modesPred, idx)
%     macroblock = blockproc(block16x16, [4, 4], @(block_struct) Intra4x4(block_struct.data, ...
%                                                                         block_struct.location, ...
%                                                                         block16x16));
% BLOCKPROC NOT WORKING - WRONG ORDER
    macroblock = zeros(size(block16x16));
    macroblock(1:4, 1:4) = block16x16(1:4, 1:4);
    
    % DAS HIER WIRD SPÄTER WEG KOMMEN
%     macroblock(5:end, 5:end) = block16x16(5:end, 5:end);
    %%%%%%%%%%%%
    
    % First Horz
    i = 1;
    for j = 1:4:16
        macroblock(i:i+3, j:j+3) = Intra4x4(block16x16(i:i+3, j:j+3), [i, j], macroblock);
    end
    
    j = 1;
    for i = 1:4:16
        macroblock(i:i+3, j:j+3) = Intra4x4(block16x16(i:i+3, j:j+3), [i, j], macroblock);
    end

    for i = 5:4:16
        for j = 5:4:16
            macroblock(i:i+3, j:j+3) = Intra4x4(block16x16(i:i+3, j:j+3), [i, j], macroblock, modesPred(idx));
            idx = idx+1;
        end
    end
    
end

function blockEnc = Intra4x4(block4x4, loc, block16x16, mode)

    if all(loc == [1, 1])
        blockEnc = block4x4;

    elseif loc(1) == 1
        blockEnc = predHor(block4x4, block16x16, loc);

    elseif loc(2) == 1
        blockEnc = predVert(block4x4, block16x16, loc);

    else
    %     blockEnc = block4x4;
        % TODO: Probably WRONG NEEDS THE MODE PART
        if mode == 0
            blockEnc = predHor(block4x4, block16x16, loc);
        elseif mode == 1
            blockEnc = predVert(block4x4, block16x16, loc);
        elseif mode == 2
            blockEnc = predDC(block4x4, block16x16, loc);
        end
%         ssd = inf;
% 
%         %Horizontal
%         pred_imHor = predHor(block4x4, block16x16, loc);
%         ssdHor = sum(abs(pred_imHor(:)));
%         if ssdHor < ssd
%             ssd = ssdHor;
%             blockEnc = pred_imHor;
%         end
% 
%         % Vertical
%         pred_imVert = predVert(block4x4, block16x16, loc);
%         ssdVert = sum(abs(pred_imVert(:)));
%         if ssdVert < ssd
%             ssd = ssdVert;
%             blockEnc = pred_imVert;
%         end
% 
%         % DC - Mean
%         pred_imDC = predDC(block4x4, block16x16, loc);
%         ssdDC = sum(abs(pred_imDC(:)));
%         if ssdDC < ssd
%             ssd = ssdDC;
%             blockEnc = pred_imDC;
%         end

        % TODO: ADD All modes

    end

end

function pred_im = predHor(block4x4, block16x16, loc)
    pred_im = block4x4 + repmat(block16x16(1:4, loc(2)-1), [1, 4]);
end

function pred_im = predVert(block4x4, block16x16, loc)
    pred_im = block4x4 + repmat(block16x16(loc(1)-1, 1:4), [4, 1]);
end

function pred_im = predDC(block4x4, block16x16, loc)
    pred_im = block4x4 + round(mean([block16x16(loc(1)-1, 1:4), block16x16(1:4, loc(2)-1)']));
end







