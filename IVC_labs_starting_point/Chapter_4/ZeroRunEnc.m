function dst = ZeroRunEnc(src)
    % place your function code here
    index = 1;
    symbol(index) = src(1);
    magnitude(index) = 1;
    for i = 2:1:length(src)
        if eq(src(i),0)
            if eq(src(i), src(i-1))
                magnitude(index) = magnitude(index) + 1;
            else
                index = index + 1;
                symbol(index) = src(i);
                magnitude(index) = 1;
            end
        else
            index = index + 1;
            symbol(index) = src(i);
            magnitude(index) = 1;
        end
    end
    dst = [];

    for i = 1:length(symbol)
        if symbol(i) == 0 
            codeTemp = [0 magnitude(i)];
        else
            codeTemp = symbol(i);
        end
        dst = [dst codeTemp];
    end


end