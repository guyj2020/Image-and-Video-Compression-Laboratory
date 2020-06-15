% EOB = 1000;
% zz = [1 0 0 2 3 4 5 1 3 0 0 0 0 0 0 0 0 1 2 3 4 0 0 0 0 0 1  4 6 8 2,...
%     4 30 0 0 0 0 2 3 5 6 7 8 9 0 3 8 2 9 29 2 0 0 0 0 0 1 3 9 4 3 0 0 0];
% zero_run_enc = ZeroRunEnc_EoB(foreman10_residual_zig_zag, EOB);

function zze = ZeroRunEnc_EoB(zz, EOB)
%  Input         : zz (Zig-zag scanned sequence, 1xN)
%                  EOB (End Of Block symbol, scalar)
%
%  Output        : zze (zero-run-level encoded sequence, 1xM)
 %%
%     zz = reshape(zz, [64, size(zz, 2)/64]);
    zz = reshape(zz, [64, numel(zz)/64]);
    zze = []; 
    for idx = 1:size(zz, 2)

        zz_idx = zz(:, idx);
        index = 1;
        symbol = [];
        magnitude = [];
        
        symbol(index) = zz_idx(1);
        magnitude(index) = 0;
        for i = 2:1:length(zz_idx)
            if eq(zz_idx(i),0)
                if eq(zz_idx(i), zz_idx(i-1))
                    magnitude(index) = magnitude(index) + 1;
                else
                    index = index + 1;
                    symbol(index) = zz_idx(i);
                    magnitude(index) = 0;
                end
            else
                index = index + 1;
                symbol(index) = zz_idx(i);
                magnitude(index) = 0;
            end
        end

        for i = 1:length(symbol)
            if symbol(i) == 0 
                if i == length(symbol)
                    codeTemp = EOB;
                else
                    codeTemp = [0 magnitude(i)];
                end
            else
                codeTemp = symbol(i);
            end
            zze = [zze codeTemp];
        end
    end
end