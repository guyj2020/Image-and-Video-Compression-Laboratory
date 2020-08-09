function [I_frameEnc, modesPred] = Intra4x4Enc(imgY, QP)
% Because blockproc is to random in it's approach of doing things-- for
% loops instead
modesPred = [];
I_frameEnc = zeros(size(imgY));
for x = 1:16:size(imgY, 1)
    for y = 1:16:size(imgY, 2)
        block16x16 = imgY(x:x+15, y:y+15);
        block16x16Enc = zeros(size(block16x16));
        for i = 1:4:16
            for j = 1:4:16
                block4x4 = block16x16(i:i+3, j:j+3);
                loc = [i, j];
                [block16x16Enc(i:i+3, j:j+3), modesPred] = Intra4x4(block4x4, loc, QP, block16x16, modesPred);
            end
        end
        I_frameEnc(x:x+15, y:y+15) = block16x16Enc;
    end
end


% I_frameEnc = blockproc(imgY, [16, 16], @(block_struct) MacroBlock(block_struct.data, QP));

end

% function macroblock = MacroBlock(block, QP)
% macroblock = blockproc(block, [4, 4], @(block_struct) Intra4x4(block_struct.data, block_struct.location, QP, block));
% end

function [blockEnc, modesPred] = Intra4x4(block4x4, loc, QP, block16x16, modesPred)
% function blockEnc = Intra4x4(block4x4, loc, QP, block16x16)
% global modesPred

if all(loc == [1, 1])
    blockEnc = IntTrafoQuant4x4(block4x4, QP);

elseif loc(1) == 1
    pred_im = predHor(block4x4, block16x16, loc);
    blockEnc = IntTrafoQuant4x4(pred_im, QP);
    
elseif loc(2) == 1
    pred_im = predVert(block4x4, block16x16, loc);
    blockEnc = IntTrafoQuant4x4(pred_im, QP);
    
else
%     blockEnc = IntTrafoQuant4x4(block4x4, QP);
    ssd = inf;
    
    %Horizontal
    pred_imHor = predHor(block4x4, block16x16, loc);
    sadHor = sum(abs(pred_imHor(:)));
    if sadHor < ssd
        ssd = sadHor;
        pred_im = pred_imHor;
        mode = 0;
    end
    
    % Vertical
    pred_imVert = predVert(block4x4, block16x16, loc);
    sadVert = sum(abs(pred_imVert(:)));
    if sadVert < ssd
        ssd = sadVert;
        pred_im = pred_imVert;
        mode = 1;
    end
    
    % DC - Mean
    pred_imDC = predDC(block4x4, block16x16, loc);
    sadDC = sum(abs(pred_imDC(:)));
    if sadDC < ssd
        ssd = sadDC;
        pred_im = pred_imDC;
        mode = 2;
    end
    
    % Diag Down Left
    pred_imDDL = predDDL(block4x4, block16x16, loc);
    sadDDL = sum(abs(pred_imDDL(:)));
    if sadDDL < ssd
        ssd = sadDDL;
        pred_im = pred_imDDL;
        mode = 3;
    end
    
    % Diag Down Right
    pred_imDDR = predDDR(block4x4, block16x16, loc);
    sadDDR = sum(abs(pred_imDDR(:)));
    if sadDDR < ssd
        ssd = sadDDR;
        pred_im = pred_imDDR;
        mode = 4;
    end
    
    % Vertical Right
    pred_imVR = predVR(block4x4, block16x16, loc);
    sadVR = sum(abs(pred_imVR(:)));
    if sadVR < ssd
        ssd = sadVR;
        pred_im = pred_imVR;
        mode = 5;
    end
    
    % Horizontal Down
    pred_imHD = predHD(block4x4, block16x16, loc);
    sadHD = sum(abs(pred_imHD(:)));
    if sadHD < ssd
        ssd = sadHD;
        pred_im = pred_imHD;
        mode = 6;
    end
        
    % Virtual Left
    pred_imVL = predVL(block4x4, block16x16, loc);
    sadVL = sum(abs(pred_imVL(:)));
    if sadVL < ssd
        ssd = sadVL;
        pred_im = pred_imVL;
        mode = 7;
    end
    
    % Horizontal Up
    pred_imHU = predHU(block4x4, block16x16, loc);
    sadUP = sum(abs(pred_imHU(:)));
    if sadUP < ssd
        ssd = sadUP;
        pred_im = pred_imHU;
        mode = 8;
    end
    
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
    pred_im = block4x4 - mean([block16x16(loc(1)-1, 1:4), block16x16(1:4, loc(2)-1)']);
end

function pred_im = predDDL(block4x4, block16x16, loc)
    block16x16 = padarray(block16x16', 4, 'post', 'replicate')';
    A = block16x16(loc(1)-1, loc(2));
    B = block16x16(loc(1)-1, loc(2)+1);
    C = block16x16(loc(1)-1, loc(2)+2);
    D = block16x16(loc(1)-1, loc(2)+3);
    E = block16x16(loc(1)-1, loc(2)+4);
    F = block16x16(loc(1)-1, loc(2)+5);
    G = block16x16(loc(1)-1, loc(2)+6);
    H = block16x16(loc(1)-1, loc(2)+7);
%     ddl_pred  = [B, C, D, E;
%                  C, D, E, F;
%                  D, E, F, G;
%                  E, F, G, H];
    ABC = (A+ 2*B + C + 2)/4;
    BCD = (B+ 2*C + D + 2)/4;
    CDE = (C+ 2*D + E + 2)/4;
    DEF = (D+ 2*E + F + 2)/4;
    EFG = (E+ 2*F + G + 2)/4;
    FGH = (F+ 2*G + H + 2)/4;
    GH =  (G+ 3*H + 2)/4;

    ddl_pred  = [ABC, BCD, CDE, DEF;
                 BCD, CDE, DEF, EFG;
                 CDE, DEF, EFG, FGH;
                 DEF, EFG, FGH, GH];

    pred_im = block4x4 - ddl_pred;
end

function pred_im = predDDR(block4x4, block16x16, loc)    
    block16x16 = padarray(block16x16', 4, 'post', 'replicate')';
    M = block16x16(loc(1)-1, loc(2)-1);
    A = block16x16(loc(1)-1, loc(2));
    B = block16x16(loc(1)-1, loc(2)+1);
    C = block16x16(loc(1)-1, loc(2)+2);
    D = block16x16(loc(1)-1, loc(2)+3);
    E = block16x16(loc(1)-1, loc(2)+4);
    F = block16x16(loc(1)-1, loc(2)+5);
    G = block16x16(loc(1)-1, loc(2)+6);
    H = block16x16(loc(1)-1, loc(2)+7);
    
    I = block16x16(loc(1), loc(2)-1);
    J = block16x16(loc(1)+1, loc(2)-1);
    K = block16x16(loc(1)+2, loc(2)-1);
    L = block16x16(loc(1)+3, loc(2)-1);

%     ddr_pred  = [M, A, B, C;
%                  I, M, A, B;
%                  J, I, M, A;
%                  K, J, I, M];
    LKJ = (L+ 2*K + J + 2)/4;
    KJI = (K+ 2*J + I + 2)/4;
    JIM = (J+ 2*I + M + 2)/4;
    IMA = (I+ 2*M + A + 2)/4;
    MAB = (M+ 2*F + B + 2)/4;
    ABC = (A+ 2*B + C + 2)/4;
    BCD = (B+ 2*C + D + 2)/4;

    ddr_pred  = [IMA, MAB, ABC, BCD;
                 JIM, IMA, MAB, ABC;
                 KJI, JIM, IMA, MAB;
                 LKJ, KJI, JIM, IMA];
    pred_im = block4x4 - ddr_pred;
end

function pred_im = predVR(block4x4, block16x16, loc)  
    M = block16x16(loc(1)-1, loc(2)-1);
    A = block16x16(loc(1)-1, loc(2));
    B = block16x16(loc(1)-1, loc(2)+1);
    C = block16x16(loc(1)-1, loc(2)+2);
    D = block16x16(loc(1)-1, loc(2)+3);
%     MA = mean([M, A]);
%     AB = mean([B, A]);
%     BC = mean([C, B]);
%     CD = mean([C, D]);
    
    I = block16x16(loc(1), loc(2)-1);
    J = block16x16(loc(1)+1, loc(2)-1);
    K = block16x16(loc(1)+2, loc(2)-1);

%     vr_pred  =  [MA, AB, BC, CD;
%                  M, A, B, C;
%                  I, MA, AB, BC;
%                  J, M, A, B];
    MA = (M + A +1)/4;
    AB = (A + B +1)/4;
    BC = (B + C +1)/4;
    CD = (C + D +1)/4;
    IMA = (I+ 2*M + A + 2)/4;
    MAB = (M+ 2*A + B + 2)/4;
    ABC = (A+ 2*B + C + 2)/4;
    BCD = (B+ 2*C + D + 2)/4;
    MIJ = (M+ 2*I + J + 2)/4;
    IJK = (I+ 2*J + K + 2)/4;

    vr_pred  =  [MA, AB, BC, CD;
                 IMA, MAB, ABC, BCD;
                 MIJ, MA, AB, BC;
                 IJK, IMA, MAB, ABC];
    pred_im = block4x4 - vr_pred;
end

function pred_im = predHD(block4x4, block16x16, loc)    
    M = block16x16(loc(1)-1, loc(2)-1);
    A = block16x16(loc(1)-1, loc(2));
    B = block16x16(loc(1)-1, loc(2)+1);
    C = block16x16(loc(1)-1, loc(2)+2);
    I = block16x16(loc(1), loc(2)-1);
    J = block16x16(loc(1)+1, loc(2)-1);
    K = block16x16(loc(1)+2, loc(2)-1);
    L = block16x16(loc(1)+3, loc(2)-1);
    
%     MI = mean([M, I]);
%     IJ = mean([I, J]);
%     JK = mean([J, K]);
%     KL = mean([K, L]);

%     hd_pred   = [MI, M, A, B;
%                  IJ, I, MI, M;
%                  JK, J, IJ, I;
%                  KL, K, JK, J];
    MI = (M + I + 1)/2;
    IMA = (I + 2*M + A + 2)/4;
    MAB = (M + 2*A + B + 2)/4;
    ABC = (A + 2*B + C + 2)/4;
    IJ = (I + J + 1)/2;
    MIJ = (M + 2*I + J + 2)/4;
    JK = (J + K + 1)/2;
    IJK = (I + 2*J + K + 2)/4;
    KL = (K + L + 1)/2;
    JKL = (J + 2*K + L + 2)/4;

    
    hd_pred   = [MI, IMA, MAB, ABC;
                 IJ, MIJ, MI, IMA;
                 JK, IJK, IJ, MIJ;
                 KL, JKL, JK, IJK];

    pred_im = block4x4 - hd_pred;
end

function pred_im = predVL(block4x4, block16x16, loc) 
    block16x16 = padarray(block16x16', 3, 'post', 'replicate')';

    A = block16x16(loc(1)-1, loc(2));
    B = block16x16(loc(1)-1, loc(2)+1);
    C = block16x16(loc(1)-1, loc(2)+2);
    D = block16x16(loc(1)-1, loc(2)+3);
    E = block16x16(loc(1)-1, loc(2)+4);
    F = block16x16(loc(1)-1, loc(2)+5);
    G = block16x16(loc(1)-1, loc(2)+6);

%     AB = mean([A, B]);
%     BC = mean([B, C]);
%     CD = mean([C, D]);
%     DE = mean([D, E]);
%     EF = mean([E, F]);
% 
%     vl_pred   = [AB, BC, CD, DE;
%                  A, B, C, D;
%                  BC, CD, DE, EF;
%                  C, D, E, F];
    AB = (A + B + 1)/2;
    BC = (B + C + 1)/2;
    CD = (C + D + 1)/2;
    DE = (D + E + 1)/2;
    EF = (E + F + 1)/2;

    ABC = (A+ 2*B + C + 2)/4;
    BCD = (B+ 2*C + D + 2)/4;
    CDE = (C+ 2*D + E + 2)/4;
    DEF = (D+ 2*E + F + 2)/4;
    EFG = (E+ 2*F + G + 2)/4;

    vl_pred   = [AB, BC, CD, DE;
                 ABC, BCD, CDE, DEF;
                 BC, CD, DE, EF;
                 BCD, CDE, DEF, EFG];

    pred_im = block4x4 - vl_pred;
end

function pred_im = predHU(block4x4, block16x16, loc) 
    I = block16x16(loc(1), loc(2)-1);
    J = block16x16(loc(1)+1, loc(2)-1);
    K = block16x16(loc(1)+2, loc(2)-1);
    L = block16x16(loc(1)+3, loc(2)-1);

%     IJ = mean([I, J]);
%     JK = mean([J, K]);
%     KL = mean([K, L]);
%     
%     hu_pred   = [IJ, J, JK, L;
%                  JK, K, KL, L;
%                  KL, L, L, L;
%                  L, L, L, L];
      
    IJ = (I + J + 1)/2;
    IJK = (I+ 2*J + K + 2)/4;
    JK = (J + K + 1)/2;
    JKL = (J+ 2*K + L + 2)/4;
    KL = (K + L + 1)/2;
    KLL = (K+ 2*L + L + 2)/4;

    hu_pred   = [IJ, IJK, JK, JKL;
                 JK, JKL, KL, KLL;
                 KL, KLL, L, L;
                 L, L, L, L];

    pred_im = block4x4 - hu_pred;
end


