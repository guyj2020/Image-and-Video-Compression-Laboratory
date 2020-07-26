function I_frameDec = Intra4x4Dec(I_frameEnc, QP, modesPred)

I_frameDecInt = blockproc(I_frameEnc, [4, 4], @(block_struct) InvIntTrafoQuant4x4(block_struct.data, QP));
% I_frameDec = blockproc(I_frameDecInt, [16, 16], @(block_struct) MacroBlock(block_struct.data));
I_frameDec = zeros(size(I_frameEnc));
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
        elseif mode == 3
            blockEnc = predDDL(block4x4, block16x16, loc);
        elseif mode == 4
            blockEnc = predDDR(block4x4, block16x16, loc);
        elseif mode == 5
            blockEnc = predVR(block4x4, block16x16, loc);
        elseif mode == 6
            blockEnc = predHD(block4x4, block16x16, loc);
        elseif mode == 7
            blockEnc = predVL(block4x4, block16x16, loc);
        elseif mode == 8
            blockEnc = predHU(block4x4, block16x16, loc);
        end
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

function pred_im = predDDL(block4x4, block16x16, loc)
    block16x16 = padarray(block16x16', 4, 'post', 'replicate')';
    B = block16x16(loc(1)-1, loc(2)+1);
    C = block16x16(loc(1)-1, loc(2)+2);
    D = block16x16(loc(1)-1, loc(2)+3);
    E = block16x16(loc(1)-1, loc(2)+4);
    F = block16x16(loc(1)-1, loc(2)+5);
    G = block16x16(loc(1)-1, loc(2)+6);
    H = block16x16(loc(1)-1, loc(2)+7);
    ddl_pred  = [B, C, D, E;
                 C, D, E, F;
                 D, E, F, G;
                 E, F, G, H];
    pred_im = block4x4 + ddl_pred;
end

function pred_im = predDDR(block4x4, block16x16, loc)    
    M = block16x16(loc(1)-1, loc(2)-1);
    A = block16x16(loc(1)-1, loc(2));
    B = block16x16(loc(1)-1, loc(2)+1);
    C = block16x16(loc(1)-1, loc(2)+2);
    
    I = block16x16(loc(1), loc(2)-1);
    J = block16x16(loc(1)+1, loc(2)-1);
    K = block16x16(loc(1)+2, loc(2)-1);

    ddr_pred  = [M, A, B, C;
                 I, M, A, B;
                 J, I, M, A;
                 K, J, I, M];
    pred_im = block4x4 + ddr_pred;
end

function pred_im = predVR(block4x4, block16x16, loc)  
    M = block16x16(loc(1)-1, loc(2)-1);
    A = block16x16(loc(1)-1, loc(2));
    B = block16x16(loc(1)-1, loc(2)+1);
    C = block16x16(loc(1)-1, loc(2)+2);
    J = block16x16(loc(1)+1, loc(2)-1);

    vr_pred  =  [M, A, B, C;
                 M, A, B, C;
                 J, M, A, B;
                 J, M, A, B];
    pred_im = block4x4 + vr_pred;
end

function pred_im = predHD(block4x4, block16x16, loc)    
    M = block16x16(loc(1)-1, loc(2)-1);
    B = block16x16(loc(1)-1, loc(2)+1);
    J = block16x16(loc(1)+1, loc(2)-1);
    K = block16x16(loc(1)+2, loc(2)-1);
    L = block16x16(loc(1)+3, loc(2)-1);

    hd_pred   = [M, M, B, B;
                 J, J, M, M;
                 K, K, J, J;
                 L, L, K, K];
    pred_im = block4x4 + hd_pred;
end

function pred_im = predVL(block4x4, block16x16, loc) 
    block16x16 = padarray(block16x16', 1, 'post', 'replicate')';

    A = block16x16(loc(1)-1, loc(2));
    B = block16x16(loc(1)-1, loc(2)+1);
    C = block16x16(loc(1)-1, loc(2)+2);
    D = block16x16(loc(1)-1, loc(2)+3);
    E = block16x16(loc(1)-1, loc(2)+4);

    vl_pred   = [A, B, C, D;
                 A, B, C, D;
                 B, C, D, E;
                 B, C, D, E];
    pred_im = block4x4 + vl_pred;
end

function pred_im = predHU(block4x4, block16x16, loc) 
    I = block16x16(loc(1), loc(2)-1);
    J = block16x16(loc(1)+1, loc(2)-1);
    K = block16x16(loc(1)+2, loc(2)-1);
    L = block16x16(loc(1)+3, loc(2)-1);

    hu_pred   = [I, I, J, J;
                 J, J, K, K;
                 K, K, L, L;
                 L, L, L, L];
    pred_im = block4x4 + hu_pred;
end


