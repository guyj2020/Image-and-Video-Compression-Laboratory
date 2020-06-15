function dst_64 = ZeroRunDec8x8_EoB(src_64, EoB)
    index = 1;
    dst_64 = zeros(1, 64);
    for i = 1:length(src_64)
        if eq(src_64(i),EoB)
            break;
        end
        if eq(src_64(i),0) 
            if i == 1 || (i > 1 && ~eq(src_64(i-1),0))
                count = src_64(i+1)+1;
                dst_64(1, index:(index+count-1)) = zeros(count,1);
                index = index + count;
            end
        else
            if (i-1) < 1 || ~eq(src_64(i-1),0)
                dst_64(1, index) = src_64(i);
                index = index + 1;
            else
                if i > 2 && and(eq(src_64(i-1),0), eq(src_64(i-2),0))
                    dst_64(1, index) = src_64(i);
                    index = index + 1;
                end
            end
        end
    end
end