% load('foreman1_residual_zig_zag');
% load('foreman2_residual_zig_zag');
load('foreman10_residual_zig_zag');
% load('lena_small_zig_zag');

% test on zig-zag sequences

% convert the zig-zag scan into a 1xN vector
% lena_small_zig_zag = lena_small_zig_zag(:)';
% foreman1_residual_zig_zag = foreman1_residual_zig_zag(:)';
% foreman2_residual_zig_zag = foreman2_residual_zig_zag(:)';
foreman10_residual_zig_zag = foreman10_residual_zig_zag(:)';

% perform ZeroRunEnc and ZeroRunDec on the sequences
% zero_run_enc = ZeroRunEnc_EoB(lena_small_zig_zag);
% zig_zag_result1 = ZeroRunDec_EoB(zero_run_enc);
% 
% zero_run_enc = ZeroRunEnc_EoB(foreman1_residual_zig_zag);
% zig_zag_result2 = ZeroRunDec_EoB(zero_run_enc);
% 
% zero_run_enc = ZeroRunEnc_EoB(foreman2_residual_zig_zag);
% zig_zag_result3 = ZeroRunDec_EoB(zero_run_enc);

zero_run_enc = ZeroRunEnc_EoB(foreman10_residual_zig_zag);
zig_zag_result4 = ZeroRunDec_EoB(zero_run_enc);

function dst = ZeroRunEnc_EoB(src)
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

function dst = ZeroRunDec_EoB(src)
    % place your function code here
    index = 1;
    for i = 1:1:length(src)
        if eq(src(i),0)
            count = src(i+1);
            dst(1, index:(index+count-1)) = zeros(count,1);
            index = index + count;
        elseif (i-1) < 1 || ~eq(src(i-1),0)
            dst(1, index) = src(i);
            index = index + 1;
        end
    end
end