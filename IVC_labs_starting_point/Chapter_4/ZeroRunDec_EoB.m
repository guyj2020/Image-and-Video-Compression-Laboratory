function dst = ZeroRunDec_EoB(src, EoB)
%  Function Name : ZeroRunDec1.m zero run level decoder
%  Input         : src (zero run encoded sequence 1xM with EoB signs)
%                  EoB (end of block sign)
%
%  Output        : dst (reconstructed zig-zag scanned sequence 1xN)
% Buf fixed but now it takes longer..
EOB_idx = find(src == EoB);
if isempty(EOB_idx)
    EOB_idx = length(src);
end

dst = [];
for idx = 1:length(EOB_idx)
    if idx == 1
        src_64 = src(1:EOB_idx(idx));
    else
        src_64 = src(EOB_idx(idx-1)+1:EOB_idx(idx));
    end
    dst_64 = ZeroRunDec8x8_EoB(src_64, EoB);
%     dst = [dst, dst_64];
    dst(1, end+1:end+size(dst_64, 2)) = dst_64;
end

end