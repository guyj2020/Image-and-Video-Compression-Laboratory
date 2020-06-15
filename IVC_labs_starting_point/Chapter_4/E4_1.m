load('foreman1_residual_zig_zag');
load('foreman2_residual_zig_zag');
load('foreman10_residual_zig_zag');
load('lena_small_zig_zag');

% test on zig-zag sequences

% convert the zig-zag scan into a 1xN vector
lena_small_zig_zag = lena_small_zig_zag(:)';
foreman1_residual_zig_zag = foreman1_residual_zig_zag(:)';
foreman2_residual_zig_zag = foreman2_residual_zig_zag(:)';
foreman10_residual_zig_zag = foreman10_residual_zig_zag(:)';

% perform ZeroRunEnc and ZeroRunDec on the sequences
zero_run_enc = ZeroRunEnc_EoB(lena_small_zig_zag);
zig_zag_result1 = ZeroRunDec_EoB(zero_run_enc);

zero_run_enc = ZeroRunEnc_EoB(foreman1_residual_zig_zag);
zig_zag_result2 = ZeroRunDec_EoB(zero_run_enc);

zero_run_enc = ZeroRunEnc_EoB(foreman2_residual_zig_zag);
zig_zag_result3 = ZeroRunDec_EoB(zero_run_enc);

zero_run_enc = ZeroRunEnc_EoB(foreman10_residual_zig_zag);
zig_zag_result4 = ZeroRunDec_EoB(zero_run_enc);

function dst = ZeroRunEnc_EoB(src)
    % place your function code here
end

function dst = ZeroRunDec_EoB(src)
    % place your function code here
end