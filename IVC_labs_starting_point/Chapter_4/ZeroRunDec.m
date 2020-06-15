function dst = ZeroRunDec(src)
    % place your function code here
    index = 1;
    for i = 1:1:length(src)
        if eq(src(i),0)
            count = src(i+1);
            dst(index:(index+count-1),1) = zeros(count,1);
            index = index + count;
        elseif (i-1) < 1 || ~eq(src(i-1),0)
            dst(index,1) = src(i);
            index = index + 1;
        end
    end
end