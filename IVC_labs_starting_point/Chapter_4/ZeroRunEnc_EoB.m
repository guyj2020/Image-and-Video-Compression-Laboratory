function zze = ZeroRunEnc_EoB(zz, EOB)
%  Input         : zz (Zig-zag scanned sequence, 1xN)
%                  EOB (End Of Block symbol, scalar)
%
%  Output        : zze (zero-run-level encoded sequence, 1xM)
 %
 %%
    zz = reshape(zz, [64, numel(zz)/64]);
    counter = 1;
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
            if length(codeTemp) == 2
                zze(counter:counter+1) = codeTemp;
                counter = counter + 2;
            else
                zze(counter) = codeTemp;
                counter = counter + 1;
            end
        end
    end
    
   
end
